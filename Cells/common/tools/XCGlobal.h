//
//  XCGlobal.h
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XCFont.h"
#import "XCColor.h"

@interface XCGlobal : NSObject

#define SYNTHESIZE_SINGLETON_FOR_HEADER(classname)\
+ (classname *)shared##classname;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
@synchronized(self) \
{ \
if (shared##classname == nil) \
{ \
shared##classname = [[super allocWithZone:NULL] init]; \
} \
} \
\
return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
return [self shared##classname];\
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
} \
\

#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height
#define SCREEN_BOUNDS UIScreen.mainScreen.bounds

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_IPHONE_X (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)
#define NAV_BAR_HEIGHT (IS_IPHONE_X ? 88.f : 64.f)

+ (NSAttributedString *)makeAttString:(NSString *)str withFont:(UIFont *)font;
+ (NSAttributedString *)makeAttString:(NSString *)str withFontSize:(int)size;
+ (NSAttributedString *)makeAttString:(NSString *)str withFontSize:(int)size withColor:(UIColor *)color;
+ (NSAttributedString *)makeAttString:(NSString *)str withFont:(UIFont *)font withColor:(UIColor *)color;
+ (NSAttributedString *)makeMultiLineAttString:(NSString *)str withFont:(UIFont *)font;
+ (NSAttributedString *)makeMultiLineAttString:(NSString *)str withFont:(UIFont *)font withColor:(UIColor *)color;
+ (NSAttributedString *)makeMultiLineAttString:(NSString *)str withFont:(UIFont *)font withColor:(UIColor *)color withLineSpacing:(NSInteger)lineSpacing;
+ (NSString *)formatYearMonth:(NSNumber *)yearMonth;
+ (NSString *)formatMsgTime:(NSTimeInterval)stamp;
+ (NSString *)formatMsgTime:(NSTimeInterval)stamp usingFormat:(NSString *)format;
+ (NSString *)formatMeetTime:(NSTimeInterval)stamp;
+ (NSString *)uuid;
+ (long)now;
+ (void)clearCookie;
+ (NSString *)formatTime:(NSTimeInterval)time;
+ (NSString *)formatDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)formatTime:(NSTimeInterval)time withFormat:(NSString *)format;
+ (NSDate *)formatDateFrom:(NSString *)date withFormat:(NSString *)format;

@end
