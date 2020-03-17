//
//  CLBasketDB.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBasket.h"
#import "CLBasketDB.h"
#import "CLBoxDB.h"
#import "CLCanister.h"
#import "CLTableVersionDB.h"
#import "NSDictionary+XCDBQuery.h"
#import "NSDictionary+XCCamelCaseKey.h"

static int const kTblVersionBasket = 0;

static NSString * const kBasketDB = @"basket.db";
static NSString * const kBasketTbl = @"basketTbl";

@implementation CLBasketDB

SYNTHESIZE_SINGLETON_FOR_CLASS(CLBasketDB);

- (void)initStore:(NSString *)baseUrl {
    NSString *path = [baseUrl stringByAppendingPathComponent:kBasketDB];
    [self initFMDatabase:path];
    @weakify(self);
    [[CLTableVersionDB sharedCLTableVersionDB]
    getTblVersionForDB:kBasketDB
           finishBlock:^(NSDictionary *versions) {
               @strongify(self);
               FMDatabase *db = [[FMDatabase alloc] initWithPath:path];
               if ([db open]) {
                   if (!versions || !versions[kBasketTbl] || (kTblVersionBasket > [versions[kBasketTbl] intValue])) {
                       [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", kBasketTbl]];
                       [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (bid integer primary key "
                                                                    @"autoincrement, name "
                                                                    @"varchar, create_time integer, canister_id integer, note varchar)",
                                                                    kBasketTbl]];
                       [[CLTableVersionDB sharedCLTableVersionDB] updateVersion:kTblVersionBasket
                                                                         forTbl:kBasketTbl
                                                                           inDB:kBasketDB];
                   }
                   [db close];
                   static dispatch_once_t runOt;
                   dispatch_once(&runOt, ^{
                       [self run];
                   });
               }
           }];
}

- (void)cacheBasket:(CLBasket *)basket withFinishBlock:(void (^)(long long))finishBlock {
    [self doWrite:[NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (name, create_time, canister_id, note) values (:name, "
                                             @":create_time, :canister_id, :note)",
                                             kBasketTbl]
       withParams:@{
           @"name": basket.name,
           @"create_time": @(basket.createTime),
           @"canister_id": @(basket.canisterId),
           @"note": basket.note
       }
      finishBlock:finishBlock];
}

- (void)getBasketsWithFinishBlock:(void (^)(NSArray<CLBasket *> *))finishBlock {
    [self getBasketsWithCond:nil finishBlock:finishBlock];
}

- (void)getBasketsWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLBasket *> *))finishBlock {
    NSDictionary *formatCond = conds ? [conds queryCond] : [@{} queryCond];
    [self doRead:[NSString stringWithFormat:@"SELECT * FROM %@%@", kBasketTbl, [formatCond objectForKey:kDBCondStr]]
      withParams:[formatCond objectForKey:kDBCondValue]
     finishBlock:^(NSArray *res) {
         NSArray *baskets =
         [MTLJSONAdapter modelsOfClass:[CLBasket class]
                         fromJSONArray:[[[res rac_sequence] map:^id(NSDictionary *metaData) {
             return [[metaData dictionaryWithValuesForKeys:@[@"bid", @"name", @"create_time", @"canister_id", @"note"]] camelCase];
         }] array]
                                 error:nil];
         finishBlock(baskets);
     }];
}

- (void)editBasket:(CLBasket *)basket withFinishBlock:(void (^)(long long))finishBlock {
    [self doWrite:[NSString stringWithFormat:@"UPDATE %@ SET name=:name, create_time=:create_time, canister_id=:canister_id, note=:note WHERE bid=%@",
                                             kBasketTbl, @(basket.bid)]
       withParams:@{
           @"name": basket.name,
           @"create_time": @(basket.createTime),
           @"canister_id": @(basket.canisterId),
           @"note": basket.note
       }
      finishBlock:finishBlock];
}

- (BFTask *)deleteBasket:(CLBasket *)basket {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [self doWrite:[NSString stringWithFormat:@"DELETE FROM %@ WHERE bid=:bid", kBasketTbl]
        withParams:@{
            @"bid": @(basket.bid)
        }
        finishBlock:^(long long lastId) {
            [tcs setResult:@(lastId)];
    }];
    [[CLBoxDB sharedCLBoxDB] deleteBoxsFromBasket:basket];
    return tcs.task;
}

- (void)deleteBasketsFromCanister:(CLCanister *)canister {
    [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{
        kDBAndCond: @[@"canister_id=:canister_id"],
        kDBAndValue: @{ @"canister_id": @(canister.cid)}
    }
    finishBlock:^(NSArray<CLBasket *> *basket) {
        NSMutableArray<CLBasket *> *baskets = [basket mutableCopy];
        for(CLBasket *b in baskets)
        {
            [self deleteBasket:b];
        }
    }];
}


@end
