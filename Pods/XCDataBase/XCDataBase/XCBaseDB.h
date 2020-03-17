//
//  XCBaseDB.h
//  XCDataBaseDemo
//
//  Created by wxc on 16/12/29.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface XCBaseDB : NSObject

typedef void (^ReadFinishBlock)(NSArray *res);
typedef void (^WriteFinishBlock)(long long lastId);

- (void)initFMDatabase:(NSString *)path;
- (void)run;
- (void)doRead:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(ReadFinishBlock)block;
- (void)doSyncRead:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(ReadFinishBlock)block;
- (void)doWrite:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(WriteFinishBlock)block;
- (void)doSyncWrite:(NSString *)sql withParams:(NSDictionary *)dictParams finishBlock:(WriteFinishBlock)block;

@end
