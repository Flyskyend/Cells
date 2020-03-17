//
//  NSDictionary+XCDBQuery.h
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kDBAndCond = @"andCond";
static NSString * const kDBAndValue = @"andValue";
static NSString * const kDBOrCond = @"orCond";
static NSString * const kDBOrValue = @"orValue";
static NSString * const kDBOrderKey = @"orderKey";
static NSString * const kDBOrderValue = @"orderValue";
static NSString * const kDBOrderASC = @"ASC";
static NSString * const kDBOrderDESC = @"DESC";
static NSString * const kDBCondStr = @"condStr";
static NSString * const kDBCondValue = @"condValue";

@interface NSDictionary (XCDBQuery)

- (NSDictionary *)queryCond;

@end
