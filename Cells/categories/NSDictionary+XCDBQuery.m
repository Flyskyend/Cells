//
//  NSDictionary+XCDBQuery.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "NSDictionary+XCDBQuery.h"

@implementation NSDictionary (XCDBQuery)

- (NSDictionary *)queryCond {
    NSMutableString *condStr = @"".mutableCopy;
    NSMutableString *orderStr = @"".mutableCopy;
    NSMutableDictionary *value = @{}.mutableCopy;
    if ([[self objectForKey:kDBAndCond] count] > 0 && [self objectForKey:kDBAndValue]) {
        [condStr appendString:[NSString stringWithFormat:@" WHERE (%@)", [[self objectForKey:kDBAndCond] componentsJoinedByString:@" AND "]]];
        [value addEntriesFromDictionary:[self objectForKey:kDBAndValue]];
    }
    if ([[self objectForKey:kDBOrCond] count] > 0 && [self objectForKey:kDBOrValue]) {
        [condStr appendString: [NSString stringWithFormat:@"%@ (%@)", condStr.length > 0 ? @" OR" : @" WHERE", [[self objectForKey:kDBOrCond] componentsJoinedByString:@" OR "]]];
        [value addEntriesFromDictionary:[self objectForKey:kDBOrValue]];
    }
    if ([self objectForKey:kDBOrderKey]) {
        [orderStr appendString:[NSString stringWithFormat:@" ORDER BY %@ %@", [self objectForKey:kDBOrderKey],
                                                          [self objectForKey:kDBOrderValue]]];
    }
    return @{ kDBCondStr: [condStr stringByAppendingString:orderStr], kDBCondValue: value };
}

@end

