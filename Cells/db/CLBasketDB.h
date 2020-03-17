//
//  CLBasketDB.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/12/2.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <XCDataBase/XCBaseDB.h>

@class CLBasket;
@class CLCanister;
@interface CLBasketDB : XCBaseDB

SYNTHESIZE_SINGLETON_FOR_HEADER(CLBasketDB);

- (void)initStore:(NSString *)baseUrl;
- (void)cacheBasket:(CLBasket *)basket withFinishBlock:(void (^)(long long lastId))finishBlock;
- (void)getBasketsWithFinishBlock:(void (^)(NSArray<CLBasket *> *baskets))finishBlock;
- (void)getBasketsWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLBasket *> *baskets))finishBlock;
- (void)editBasket:(CLBasket *)basket withFinishBlock:(void (^)(long long))finishBlock;
- (BFTask *)deleteBasket:(CLBasket *)basket;
- (void)deleteBasketsFromCanister:(CLCanister *)canister;

@end
