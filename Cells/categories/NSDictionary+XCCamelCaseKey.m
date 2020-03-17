//
//  NSDictionary+XCCamelCaseKey.m
//  Swan
//
//  Created by wxc on 15/10/25.
//  Copyright © 2015年 wxc. All rights reserved.
//

#import "NSDictionary+XCCamelCaseKey.h"

@implementation NSDictionary (SWCamelCaseKey)

- (NSDictionary *)camelCase
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *camelCaseKey ;
        if ([key isKindOfClass:[NSString class]] && [key rangeOfString:@"_"].location != NSNotFound) {
            camelCaseKey = [NSString stringWithFormat:@"%@%@",
                            [key substringToIndex:1], [[[[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] substringFromIndex:1]];
        } else {
            camelCaseKey = key;
        }
        ret[camelCaseKey] = obj;
    }];
    return ret;
}

@end
