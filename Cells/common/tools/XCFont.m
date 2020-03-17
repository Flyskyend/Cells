//
//  XCFont.m
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "XCFont.h"

@implementation XCFont

+ (UIFont *)boldFontWithSize:(int)size {
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)lightFontWithSize:(int)size {
    return [UIFont systemFontOfSize:size];
}

#pragma mark - Added font.

+ (UIFont *)HYQiHeiWithFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"HYQiHei-BEJF" size:size];
}

#pragma mark - System font.

+ (UIFont *)AppleSDGothicNeoThinWithFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:size];
}

+ (UIFont *)AvenirWithFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"Avenir" size:size];
}

+ (UIFont *)AvenirLightWithFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"Avenir-Light" size:size];
}

+ (UIFont *)HeitiSCWithFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"Heiti SC" size:size];
}

+ (UIFont *)HelveticaNeueFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)HelveticaNeueBoldFontSize:(CGFloat)size {

    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

@end

