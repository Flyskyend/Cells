//
//  XCGlobal.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "XCGlobal.h"
#import "NSDate+XCDateStringMutualConvertion.h"

@implementation XCGlobal

+ (NSAttributedString *)makeAttString:(NSString *)str withFontSize:(int)fontSize {
    return [XCGlobal makeAttString:str withFont:[XCFont lightFontWithSize:fontSize]];
}

+ (NSAttributedString *)makeAttString:(NSString *)str withFont:(UIFont *)font {
    return [XCGlobal makeAttString:str withFont:font withColor:[UIColor blackColor]];
}

+ (NSAttributedString *)makeAttString:(NSString *)str withFontSize:(int)size withColor:(UIColor *)color {
    return [XCGlobal makeAttString:str withFont:[XCFont lightFontWithSize:size] withColor:color];
}

+ (NSAttributedString *)makeAttString:(NSString *)str withFont:(UIFont *)font withColor:(UIColor *)color {
    if (!str) {
        str = @"";
    }
    return [[NSAttributedString alloc] initWithString:str
                                           attributes:@{ NSFontAttributeName: font, NSForegroundColorAttributeName: color }];
}

+ (NSAttributedString *)makeMultiLineAttString:(NSString *)str withFont:(UIFont *)font {
    return [XCGlobal makeMultiLineAttString:str withFont:font withColor:[UIColor blackColor]];
}

+ (NSAttributedString *)makeMultiLineAttString:(NSString *)str withFont:(UIFont *)font withColor:(UIColor *)color {
    return [XCGlobal makeMultiLineAttString:str withFont:font withColor:color withLineSpacing:3];
}

+ (NSAttributedString *)makeMultiLineAttString:(NSString *)str
                                      withFont:(UIFont *)font
                                     withColor:(UIColor *)color
                               withLineSpacing:(NSInteger)lineSpacing {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [paragraphStyle setLineSpacing:lineSpacing];
    if (!str) {
        str = @"";
    }
    return [[NSAttributedString alloc] initWithString:str
                                           attributes:@{
                                               NSParagraphStyleAttributeName: paragraphStyle,
                                               NSFontAttributeName: font,
                                               NSForegroundColorAttributeName: color
                                           }];
}

+ (NSString *)formatYearMonth:(NSNumber *)yearMonth {
    if ([yearMonth intValue] < 0) {
        return [NSString stringWithFormat:@"公元前 %d.%02d", -([yearMonth intValue]) / 100, -([yearMonth intValue]) % 100];
    }
    return [NSString stringWithFormat:@"%d.%02d", [yearMonth intValue] / 100, [yearMonth intValue] % 100];
}

+ (NSString *)formatMsgTime:(NSTimeInterval)stamp {
    return [XCGlobal formatMsgTime:stamp usingFormat:nil];
}

+ (NSString *)formatMsgTime:(NSTimeInterval)stamp usingFormat:(NSString *)format {
    NSDate *now = [NSDate date];
    double ti = stamp - [now timeIntervalSince1970];
    ti = ti * -1;
    if (ti < 1) {
        return @"刚刚";
    } else if (ti < 60) {
        int diff = floor(ti);
        return [NSString stringWithFormat:@"%d 秒前", diff];
    } else if (ti < 3600) {
        int diff = floor(ti / 60);
        return [NSString stringWithFormat:@"%d 分钟前", diff];
    } else if (ti < 86400 && stamp >= [[now beginningOfDay] timeIntervalSince1970]) {
        int diff = floor(ti / 60 / 60);
        return [NSString stringWithFormat:@"%d 小时前", diff];
    } else if (ti < 4 * 86400) {
        int diff = (int)ceil(([[now beginningOfDay] timeIntervalSince1970] - stamp) / 60 / 60 / 24);
        if (!format) {
            return [NSString stringWithFormat:@"%d 天前", diff];
        }
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:format];
        return [NSString stringWithFormat:@"%d 天前 %@", diff, [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:stamp]]];
    } else {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        if (!format) {
            [df setDateFormat:@"M月d日"];
        } else {
            [df setDateFormat:[NSString stringWithFormat:@"M月d日 %@", format]];
        }
        return [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:stamp]];
    }
}

+ (NSString *)formatMeetTime:(NSTimeInterval)stamp {
    NSDate *now = [NSDate date];
    double ti = stamp - [now timeIntervalSince1970];
    if (ti < 0) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM月 d日"];
        return [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:stamp]];
    } else if (stamp < [[[NSDate date] beginningOfDay] timeIntervalSince1970] + 86400) {
        return @"今天";
    } else {
        int days = ceil(([[[NSDate dateWithTimeIntervalSince1970:stamp] beginningOfDay] timeIntervalSince1970] -
                         ([[[NSDate date] beginningOfDay] timeIntervalSince1970] + 86399)) /
                        86400.f) +
                   1;
        if (days <= 1) {
            return @"明天";
        }
        return [NSString stringWithFormat:@"最近%@天", @(days)];
    }
}

+ (NSString *)uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStrRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *retStr = [NSString stringWithString:(__bridge NSString *)uuidStrRef];
    CFRelease(uuidStrRef);
    return retStr;
}

+ (long)now {
    return ceil([[NSDate date] timeIntervalSince1970]);
}

+ (void)clearCookie {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)formatDate:(NSDate *)date withFormat:(NSString *)format {
    return [XCGlobal formatTime:[date timeIntervalSince1970] withFormat:format];
}

+ (NSString *)formatTime:(NSTimeInterval)time {
    return [XCGlobal formatTime:time withFormat:@"yyyy-MM-dd HH:mm"];
}

+ (NSString *)formatTime:(NSTimeInterval)time withFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    return [formatter stringFromDate:date];
}

+ (NSDate *)formatDateFrom:(NSString *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:format];
    return [formatter dateFromString:date];
}

@end
