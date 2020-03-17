//
//  XCMessageHelper.h
//  XCMessageHelperDemo
//
//  Created by wxc on 16/12/30.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface XCMessageHelper : NSObject

#pragma - wrapper of MBProgressHUD that will disable interaction with app
+ (void)showHUDMessage:(NSString *)message;
+ (void)showHUDMessage:(NSString *)message detail:(NSString *)detail;
+ (void)showHUDImage:(NSString *)imageName;
+ (void)showHudMessage:(NSString *)message image:(NSString *)imageName;
+ (void)showHudMessage:(NSString *)message detail:(NSString *)detail image:(NSString *)imageName;

+ (void)showHUDActivity:(UIView *)parentView;
+ (void)showHUDActivity:(UIView *)parentView hideAfter:(int)time;
+ (void)showHUDActivity:(NSString *)message parentView:(UIView *)parentView;
+ (void)hideHUDActivity:(UIView *)parentView;
+ (void)showHUDActivity:(UIView *)parentView forKey:(NSString *)key;
+ (void)hideHUDActivityWithoutAnimation:(UIView *)parentView;
+ (void)hideHUDActivityWithoutAnimation:(UIView *)parentView forKey:(NSString *)key;

#pragma - creates a view and displays it as toast
+ (void)showMessage:(NSString *)message;
+ (void)showMessage:(NSString *)message duration:(CGFloat)interval position:(id)position;
+ (void)showMessage:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title;
+ (void)showMessage:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title image:(UIImage *)image;
+ (void)showMessage:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image;

#pragma - displays toast with an activity spinner
+ (void)showActivity;
+ (void)showActivity:(id)position;
+ (void)hideActivity;

#pragma - the showView methods display any view as toast
+ (void)showView:(UIView *)toast;
+ (void)showView:(UIView *)toast duration:(CGFloat)interval position:(id)point;

#pragma - 获取当前应用的顶级窗口
+ (UIWindow *)getTopWindow;

@end
