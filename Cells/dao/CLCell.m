//
//  CLCell.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Uptated by 罗劭衡 on 2019/11/24.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCell.h"

@implementation CLCell

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        NSStringFromSelector(@selector(name)): @"name",
        NSStringFromSelector(@selector(cellId)): @"cellId",
        NSStringFromSelector(@selector(boxId)): @"boxId",
        NSStringFromSelector(@selector(boxIndex)): @"boxIndex",
        NSStringFromSelector(@selector(createTime)): @"createTime",
        NSStringFromSelector(@selector(note)): @"note"
    };
}

@end
