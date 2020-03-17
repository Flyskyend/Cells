//
//  CLBoxDB.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <XCDataBase/XCBaseDB.h>

@class CLBox;
@class CLBasket;
@interface CLBoxDB : XCBaseDB

SYNTHESIZE_SINGLETON_FOR_HEADER(CLBoxDB);
- (void)initStore:(NSString *)baseUrl;
- (BFTask *)deleteBox:(CLBox *)box;
- (void)cacheBox:(CLBox *)box withFinishBlock:(void (^)(long long lastId))finishBlock;
- (void)editBox:(CLBox *)box withFinishBlock:(void (^)(long long lastId))finishBlock;
- (void)getBoxsWithFinishBlock:(void (^)(NSArray<CLBox *> *boxs))finishBlock;
- (void)getBoxsWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLBox *> *boxs))finishBlock;
- (void)deleteBoxsFromBasket:(CLBasket *)basket;

@end
