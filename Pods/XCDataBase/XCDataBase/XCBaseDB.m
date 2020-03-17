//
//  XCBaseDB.m
//  XCDataBaseDemo
//
//  Created by wxc on 16/12/29.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import "XCBaseDB.h"
#import "XCUnboundedBlockingQueue.h"

@interface XCBaseDB()

@property(nonatomic, strong) NSLock *rLock;
@property(nonatomic, strong) NSLock *wLock;
@property(nonatomic, strong) FMDatabase *rdb;
@property(nonatomic, strong) FMDatabase *wdb;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, strong) XCUnboundedBlockingQueue *readQueue;
@property(nonatomic, strong) XCUnboundedBlockingQueue *writeQueue;
@property(nonatomic, strong) dispatch_queue_t dbRq;
@property(nonatomic, strong) dispatch_queue_t dbWq;

@end

@implementation XCBaseDB

- (instancetype)init {
  self = [super init];
  if (self) {
    _rLock = [[NSLock alloc] init];
    _wLock = [[NSLock alloc] init];
  }
  return self;
}

- (void)initFMDatabase:(NSString *)path {
    _path = path;
    [_readQueue clear];
    [_writeQueue clear];
    while (![_rLock tryLock]) {
    }
    _rdb = [[FMDatabase alloc] initWithPath:_path];
    [_rLock unlock];
    while (![_wLock tryLock]) {
    }
    _wdb = [[FMDatabase alloc] initWithPath:_path];
    [_wLock unlock];
}

- (void)run {
    _readQueue = [[XCUnboundedBlockingQueue alloc] init];
    _writeQueue = [[XCUnboundedBlockingQueue alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (true) {
            NSArray *elm = [_readQueue take];
            if (nil != elm) {
                [_rLock lock];
                [_rdb open];
                NSString *sql = elm[0];
                NSDictionary *params = [elm[1] isEqual:[NSNull null]] ? nil : elm[1];
                ReadFinishBlock block = elm[2];
                FMResultSet *res =
                [_rdb executeQuery:sql withParameterDictionary:params];
                NSMutableArray *ret = [[NSMutableArray alloc] init];
                while ([res next]) {
                    [ret addObject:[res resultDictionary]];
                }
                [_rdb close];
                [_rLock unlock];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(ret);
                    });
                }
            }
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (true) {
            NSArray *elm = [_writeQueue take];
            if (nil != elm) {
                [_wLock lock];
                [_wdb open];
                NSString *sql = elm[0];
                NSDictionary *params = [elm[1] isEqual:[NSNull null]] ? nil : elm[1];
                WriteFinishBlock block = elm[2];
                long long lastId;
                if ([_wdb executeUpdate:sql withParameterDictionary:params]) {
                    lastId = [_wdb lastInsertRowId];
                } else {
                    lastId = -_wdb.lastErrorCode;
                }
                [_wdb close];
                [_wLock unlock];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[sql uppercaseString] hasPrefix:@"INSERT"]) {
                            block(lastId);
                        } else {
                            block(0);
                        }
                    });
                }
            }
        }
    });
}

- (void)doRead:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(ReadFinishBlock)block {
    if (nil == _readQueue) {
        return block(nil);
    }
    [_readQueue put:@[sql, (dictParams ? dictParams : [NSNull null]), (block ? block : ^(NSArray *ret){})]];
}

- (void)doSyncRead:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(ReadFinishBlock)block {
    FMDatabase *db = [[FMDatabase alloc] initWithPath:_path];
    [db open];
    FMResultSet *res = [db executeQuery:sql withParameterDictionary:dictParams];
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    while ([res next]) {
        [ret addObject:[res resultDictionary]];
    }
    [db close];
    block(ret);
}

- (void)doWrite:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(WriteFinishBlock)block {
    [_writeQueue put:@[sql, (dictParams ? dictParams : [NSNull null]), (block ? block : ^(long long lastId){})]];
}

- (void)doSyncWrite:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(WriteFinishBlock)block {
    long long lastId;
    FMDatabase *db = [[FMDatabase alloc] initWithPath:_path];
    [db open];
    if ([db executeUpdate:sql withParameterDictionary:dictParams]) {
        lastId = [db lastInsertRowId];
    } else {
        lastId = -db.lastErrorCode;
    }
    [db close];
    block(lastId);
}

@end
