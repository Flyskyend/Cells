//
//  CLBoxDB.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBox.h"
#import "CLBoxDB.h"
#import "CLCellDB.h"
#import "CLBasket.h"
#import "CLTableVersionDB.h"
#import "NSDictionary+XCDBQuery.h"
#import "NSDictionary+XCCamelCaseKey.h"

static int const kTblVersionBox = 1;

static NSString * const kBoxDB = @"box.db";
static NSString * const kBoxTbl = @"boxTbl";
static NSString * const kCellTbl = @"cellTbl";

@implementation CLBoxDB

SYNTHESIZE_SINGLETON_FOR_CLASS(CLBoxDB);

- (void)initStore:(NSString *)baseUrl {
    NSString *path = [baseUrl stringByAppendingPathComponent:kBoxDB];
    [self initFMDatabase:path];
    @weakify(self);
    [[CLTableVersionDB sharedCLTableVersionDB]
    getTblVersionForDB:kBoxDB
           finishBlock:^(NSDictionary *versions) {
               @strongify(self);
               FMDatabase *db = [[FMDatabase alloc] initWithPath:path];
               if ([db open]) {
                   if (!versions || !versions[kBoxTbl] || (kTblVersionBox > [versions[kBoxTbl] intValue])) {
                       [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", kBoxTbl]];
                       [db executeUpdate:[NSString
                                         stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (bid integer primary key "
                                                          @"autoincrement, name "
                                                          @"varchar, create_time integer, basket_id integer, row integer, "
                                                          @"column integer, note varchar)",
                                                          kBoxTbl]];
                       [[CLTableVersionDB sharedCLTableVersionDB] updateVersion:kTblVersionBox forTbl:kBoxTbl inDB:kBoxDB];
                   }
                   [db close];
                   static dispatch_once_t runOt;
                   dispatch_once(&runOt, ^{
                       [self run];
                   });
               }
           }];
}

- (void)cacheBox:(CLBox *)box withFinishBlock:(void (^)(long long))finishBlock {
    [self doWrite:[NSString
                  stringWithFormat:@"INSERT OR REPLACE INTO %@ (name, create_time, basket_id, row, column, note) values (:name, "
                                   @":create_time, :basket_id, :row, :column, :note)",
                                   kBoxTbl]
       withParams:@{
           @"name": box.name,
           @"create_time": @(box.createTime),
           @"basket_id": @(box.basketId),
           @"row": @(box.row),
           @"column": @(box.column),
           @"note": box.note
       }
      finishBlock:finishBlock];
}

- (void)getBoxsWithFinishBlock:(void (^)(NSArray<CLBox *> *))finishBlock {
    [self getBoxsWithCond:nil finishBlock:finishBlock];
}

- (void)getBoxsWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLBox *> *))finishBlock {
    //NSLog(@"\n---------Conds:%@",conds);
    NSDictionary *formatCond = conds ? [conds queryCond] : [@{} queryCond];
    [self doRead:[NSString stringWithFormat:@"SELECT * FROM %@%@", kBoxTbl, [formatCond objectForKey:kDBCondStr]]
      withParams:[formatCond objectForKey:kDBCondValue]
     finishBlock:^(NSArray *res) {
         NSArray *boxs = [MTLJSONAdapter
         modelsOfClass:[CLBox class]
         fromJSONArray:[[[res rac_sequence] map:^id(NSDictionary *metaData) {
             return [[metaData dictionaryWithValuesForKeys:@[@"bid", @"name", @"create_time", @"basket_id", @"row", @"column", @"note"]] camelCase];
         }] array]
                 error:nil];
         finishBlock(boxs);
     }];
}

- (void)editBox:(CLBox *)box withFinishBlock:(void (^)(long long))finishBlock {
    //Flyskyend changed
    [self doWrite:[NSString stringWithFormat:@"UPDATE %@ SET name=:name, create_time=:create_time, row=:row, column=:column, basket_id=:basketId, note=:note WHERE bid=%@",
                                             kBoxTbl, @(box.bid)]
       withParams:@{
           @"name": box.name,
           @"create_time": @(box.createTime),
           @"row": @(box.row),
           @"column": @(box.column),
           @"basketId": @(box.basketId),
           @"note": box.note
       }
      finishBlock:finishBlock];
}

- (BFTask *)deleteBox:(CLBox *)box {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [self doWrite:[NSString stringWithFormat:@"DELETE FROM %@ WHERE bid=:bid", kBoxTbl]
        withParams:@{
            @"bid": @(box.bid)
        }
        finishBlock:^(long long lastId) {
            [tcs setResult:@(lastId)];
    }];
    [[CLCellDB sharedCLCellDB] deleteCellsFromBox:box];
    return tcs.task;
}

- (void)deleteBoxsFromBasket:(CLBasket *)basket {
    [[CLBoxDB sharedCLBoxDB] getBoxsWithCond:@{
        kDBAndCond: @[@"basket_id=:basket_id"],
        kDBAndValue: @{ @"basket_id": @(basket.bid) }
    }
    finishBlock:^(NSArray<CLBox *> *box) {
        NSMutableArray<CLBox *> *boxs = [box mutableCopy];
        for(CLBox *b in boxs)
        {
            [self deleteBox:b];
        }
    }];
}

@end
