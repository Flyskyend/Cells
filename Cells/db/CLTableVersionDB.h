//
//  CLTableVersionDB.h
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <XCDataBase/XCBaseDB.h>

@interface CLTableVersionDB : XCBaseDB

SYNTHESIZE_SINGLETON_FOR_HEADER(CLTableVersionDB);

- (void)getTblVersionForDB:(NSString *)db finishBlock:(void(^)(NSDictionary *))finishBlock;
- (void)getVersionForTbl:(NSString *)tbl inDB:(NSString *)db finishBlock:(void(^)(int version))finishBlock;
- (void)updateVersion:(int)version forTbl:(NSString *)tbl inDB:(NSString *)db;
- (void)initStore:(NSString *)baseUrl;

@end
