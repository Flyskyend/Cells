//
//  NSDate+XCDateStringMutualConvertion.h
//  Swan
//
//  Created by wxc on 15/10/18.
//  Copyright © 2015年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (XCDateStringMutualConvertion)

+ (void)initializeStatics;

+ (NSCalendar *)sharedCalendar;
+ (NSDateFormatter *)sharedDateFormatter;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger daysAgo;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger daysAgoAgainstMidnight;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger weekday;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *displayWeekday;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *displayShortWeekday;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger weekNumber;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger hour;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger minute;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger year;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger month;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger day;
@property (NS_NONATOMIC_IOSONLY, readonly) long utcTimeStamp; //full seconds since
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *beginningOfWeek;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *beginningOfDay;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *endOfWeek;
+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

+ (NSDateComponents *)componentsOfCurrentDate;
+ (NSDateComponents *)componentsOfDate:(NSDate *)date;
+ (NSDateComponents *)componentsWithHour:(NSInteger)hour min:(NSInteger)min;

- (BOOL)date:(NSDate *)dateA isTheSameMonthThan:(NSDate *)dateB;
- (BOOL)date:(NSDate *)dateA isTheSameWeekThan:(NSDate *)dateB;
- (BOOL)date:(NSDate *)dateA isTheSameDayThan:(NSDate *)dateB;

- (NSDate *)dateByAddingYears:(NSInteger) dYears;
- (NSDate *)dateBySubtractingYears:(NSInteger) dYears;
- (NSDate *)dateByAddingMonths:(NSInteger) dMonths;
- (NSDate *)dateBySubtractingMonths:(NSInteger) dMonths;
- (NSDate *)dateByAddingDays:(NSInteger) dDays;
- (NSDate *)dateBySubtractingDays:(NSInteger) dDays;
- (NSDate *)dateByAddingHours:(NSInteger) dHours;
- (NSDate *)dateBySubtractingHours:(NSInteger) dHours;
- (NSDate *)dateByAddingMinutes:(NSInteger) dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSInteger) dMinutes;
- (NSDate *)dateByAddingSeconds:(NSInteger) dSeconds;
- (NSDate *)dateBySubtractingSeconds:(NSInteger) dSeconds;

- (NSInteger)week;

@end
