//
//  CLCanisterDB.h
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Updated by 罗劭衡 on 2019/12/2.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <XCDataBase/XCBaseDB.h>

@class CLCanister;
@interface CLCanisterDB : XCBaseDB

SYNTHESIZE_SINGLETON_FOR_HEADER(CLCanisterDB);

- (void)initStore:(NSString *)baseUrl;
- (void)cacheCanister:(CLCanister *)canister withFinishBlock:(void (^)(long long lastId))finishBlock;
- (void)getCanistersWithFinishBlock:(void (^)(NSArray<CLCanister *> *canisters))finishBlock;
- (void)getCanistersWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLCanister *> *canisters))finishBlock;
- (void)editCanister:(CLCanister *)canister withFinishBlock:(void (^)(long long))finishBlock;
- (BFTask *)deleteCanister:(CLCanister *)canister;

@end
