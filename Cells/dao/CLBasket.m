//
//  CLBasket.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBasket.h"

@implementation CLBasket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        NSStringFromSelector(@selector(name)): @"name",
        NSStringFromSelector(@selector(bid)): @"bid",
        NSStringFromSelector(@selector(canisterId)): @"canisterId",
        NSStringFromSelector(@selector(createTime)): @"createTime",
        NSStringFromSelector(@selector(note)): @"note"
    };
}

@end
