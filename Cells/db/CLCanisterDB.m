//
//  CLCanisterDB.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCanisterDB.h"
#import "CLCanister.h"
#import "CLBasketDB.h"
#import "CLTableVersionDB.h"
#import "NSDictionary+XCDBQuery.h"
#import "NSDictionary+XCCamelCaseKey.h"

static int const kTblVersionCanister = 0;

static NSString * const kCanisterDB = @"canister.db";
static NSString * const kCanisterTbl = @"canisterTbl";

@implementation CLCanisterDB

SYNTHESIZE_SINGLETON_FOR_CLASS(CLCanisterDB);

- (void)initStore:(NSString *)baseUrl {
    NSString *path = [baseUrl stringByAppendingPathComponent:kCanisterDB];
    [self initFMDatabase:path];
    @weakify(self);
    [[CLTableVersionDB sharedCLTableVersionDB]
    getTblVersionForDB:kCanisterDB
           finishBlock:^(NSDictionary *versions) {
               @strongify(self);
               FMDatabase *db = [[FMDatabase alloc] initWithPath:path];
               if ([db open]) {
                   if (!versions || !versions[kCanisterTbl] || (kTblVersionCanister > [versions[kCanisterTbl] intValue])) {
                       [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", kCanisterTbl]];
                       [db
                       executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid integer primary key autoincrement, name "
                                                                @"varchar, create_time integer, note varchar)",
                                                                kCanisterTbl]];
                       [[CLTableVersionDB sharedCLTableVersionDB] updateVersion:kTblVersionCanister
                                                                         forTbl:kCanisterTbl
                                                                           inDB:kCanisterDB];
                   }
                   [db close];
                   static dispatch_once_t runOt;
                   dispatch_once(&runOt, ^{
                       [self run];
                   });
               }
           }];
}

- (void)cacheCanister:(CLCanister *)canister withFinishBlock:(void (^)(long long))finishBlock {
    [self doWrite:[NSString
                  stringWithFormat:@"INSERT OR REPLACE INTO %@ (name, create_time, note) values (:name, :create_time, :note)", kCanisterTbl]
       withParams:@{
           @"name": canister.name,
           @"create_time": @(canister.createTime),
           @"note": canister.note
       }
      finishBlock:finishBlock];
}

- (void)getCanistersWithFinishBlock:(void (^)(NSArray<CLCanister *> *))finishBlock {
    [self getCanistersWithCond:nil finishBlock:finishBlock];
}

- (void)getCanistersWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLCanister *> *))finishBlock {
    NSDictionary *formatCond = conds ? [conds queryCond] : [@{} queryCond];
    [self doRead:[NSString stringWithFormat:@"SELECT * FROM %@%@", kCanisterTbl, [formatCond objectForKey:kDBCondStr]]
      withParams:[formatCond objectForKey:kDBCondValue]
     finishBlock:^(NSArray *res) {
         NSArray *canisters =
         [MTLJSONAdapter modelsOfClass:[CLCanister class]
                         fromJSONArray:[[[res rac_sequence] map:^id(NSDictionary *metaData) {
                             return [[metaData dictionaryWithValuesForKeys:@[@"cid", @"name", @"create_time", @"note"]] camelCase];
                         }] array]
                                 error:nil];
         finishBlock(canisters);
     }];
}

- (void)editCanister:(CLCanister *)canister withFinishBlock:(void (^)(long long))finishBlock {
    [self doWrite:[NSString stringWithFormat:@"UPDATE %@ SET name=:name, create_time=:create_time, note=:note WHERE cid=%@",
                                             kCanisterTbl, @(canister.cid)]
       withParams:@{
           @"name": canister.name,
           @"create_time": @(canister.createTime),
           @"note": canister.note
       }
      finishBlock:finishBlock];
}

- (BFTask *)deleteCanister:(CLCanister *)canister {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [self doWrite:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=:cid", kCanisterTbl]
        withParams:@{
            @"cid": @(canister.cid)
        }
        finishBlock:^(long long lastId) {
            [tcs setResult:@(lastId)];
    }];
    [[CLBasketDB sharedCLBasketDB] deleteBasketsFromCanister:canister];
    return tcs.task;
}

@end
