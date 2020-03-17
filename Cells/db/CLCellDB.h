//
//  CLCellDB.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <XCDataBase/XCBaseDB.h>

@class CLCell;
@class CLBox;
@interface CLCellDB : XCBaseDB

SYNTHESIZE_SINGLETON_FOR_HEADER(CLCellDB);

- (void)initStore:(NSString *)baseUrl;
- (BFTask *)deleteCell:(CLCell *)cell;
- (BFTask *)deleteCellsFromBox:(CLBox *)box;
- (void)cacheCell:(CLCell *)cell withFinishBlock:(void (^)(long long lastId))finishBlock;
- (void)cacheCells:(NSArray<CLCell *> *)cells withFinishBlock:(void (^)(NSArray<CLCell *>* cells))finishBlock;
- (void)editCell:(CLCell *)cell withFinishBlock:(void (^)(long long lastId))finishBlock;
- (void)getCellsWithFinishBlock:(void (^)(NSArray<CLCell *> *cells))finishBlock;
- (void)getCellsWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLCell *> *cells))finishBlock;

@end
