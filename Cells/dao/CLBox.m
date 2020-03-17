//
//  CLBox.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBox.h"

@implementation CLBox

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             NSStringFromSelector(@selector(bid)): @"bid",
             NSStringFromSelector(@selector(name)): @"name",
             NSStringFromSelector(@selector(row)): @"row",
             NSStringFromSelector(@selector(column)): @"column",
             NSStringFromSelector(@selector(basketId)): @"basketId",
             NSStringFromSelector(@selector(createTime)): @"createTime",
             NSStringFromSelector(@selector(note)): @"note"
             };
}

@end
