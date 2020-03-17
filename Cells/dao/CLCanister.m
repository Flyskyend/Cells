//
//  CLCanister.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCanister.h"

@implementation CLCanister

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        NSStringFromSelector(@selector(cid)): @"cid",
        NSStringFromSelector(@selector(name)): @"name",
        NSStringFromSelector(@selector(createTime)): @"createTime",
        NSStringFromSelector(@selector(note)): @"note"
    };
}

@end
