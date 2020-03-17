//
//  XCMessageHelper.m
//  XCMessageHelperDemo
//
//  Created by wxc on 16/12/30.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import "XCMessageHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Toast+UIView.h"

@implementation XCMessageHelper

+ (UIWindow *)getTopWindow
{
    NSInteger i = [UIApplication sharedApplication].windows.count - 1;
    while (i >= 0) {
        if ([[UIApplication sharedApplication].windows[i] isMemberOfClass:UIWindow.class]) {
            return [UIApplication sharedApplication].windows[i];
        }
        i --;
    }
    return [UIApplication sharedApplication].windows.lastObject;
}

#pragma - creates a view and displays it as toast
+ (void)showMessage:(NSString *)message
{
    [[XCMessageHelper getTopWindow] makeToast:message];
}

+ (void)showMessage:(NSString *)message
           duration:(CGFloat)interval
           position:(id)position
{
    [[XCMessageHelper getTopWindow] makeToast:message
                                     duration:interval
                                     position:position];
}

+ (void)showMessage:(NSString *)message
           duration:(CGFloat)interval
           position:(id)position
              title:(NSString *)title
{
    [[XCMessageHelper getTopWindow] makeToast:message
                                     duration:interval
                                     position:position
                                        title:title];
}

+ (void)showMessage:(NSString *)message
           duration:(CGFloat)interval
           position:(id)position
              title:(NSString *)title
              image:(UIImage *)image
{
    [[XCMessageHelper getTopWindow] makeToast:message
                                     duration:interval
                                     position:position
                                        title:title
                                        image:image];
}

+ (void)showMessage:(NSString *)message
           duration:(CGFloat)interval
           position:(id)position
              image:(UIImage *)image
{
    [[XCMessageHelper getTopWindow] makeToast:message
                                     duration:interval
                                     position:position
                                        image:image];
}

#pragma - displays toast with an activity spinner
+ (void)showActivity
{
    [[XCMessageHelper getTopWindow] makeToastActivity];
}

+ (void)showActivity:(id)position
{
    [[XCMessageHelper getTopWindow] makeToastActivity:position];
}

+ (void)hideActivity
{
    [[XCMessageHelper getTopWindow] hideToastActivity];
}

#pragma - the showView methods display any view as toast
+ (void)showView:(UIView *)toast
{
    [[XCMessageHelper getTopWindow] showToast:toast];
}

+ (void)showView:(UIView *)toast
        duration:(CGFloat)interval
        position:(id)point
{
    [[XCMessageHelper getTopWindow] showToast:toast
                                     duration:interval
                                     position:point];
}

#pragma - wrapper of MBProgressHUD that will disable interaction with app
+ (void)showHUDMessage:(NSString *)message
{
    UIWindow *window = [XCMessageHelper getTopWindow];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabel.font = [UIFont systemFontOfSize:16];
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeText;
    [hud showWhileExecuting:@selector(delayTask) onTarget:self withObject:nil animated:YES];
}

+ (void)showHUDMessage:(NSString *)message detail:(NSString *)detail
{
    UIWindow *window = [XCMessageHelper getTopWindow];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = message;
    hud.detailsLabel.text = detail;
    hud.mode = MBProgressHUDModeText;
    [hud showWhileExecuting:@selector(delayTask) onTarget:self withObject:nil animated:YES];
}

+ (void)showHUDImage:(NSString *)imageName
{
    UIWindow *window = [XCMessageHelper getTopWindow];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [hud showWhileExecuting:@selector(delayTask) onTarget:self withObject:nil animated:YES];
}

+ (void)showHudMessage:(NSString *)message image:(NSString *)imageName
{
    UIWindow *window = [XCMessageHelper getTopWindow];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = message;
    hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [hud showWhileExecuting:@selector(delayTask) onTarget:self withObject:nil animated:YES];
}

+ (void)showHudMessage:(NSString *)message detail:(NSString *)detail image:(NSString *)imageName
{
    UIWindow *window = [XCMessageHelper getTopWindow];
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = message;
    hud.detailsLabel.text = detail;
    hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [hud showWhileExecuting:@selector(delayTask) onTarget:self withObject:nil animated:YES];
}

+ (void)delayTask
{
    [NSThread sleepForTimeInterval:1.5];
}

+ (void)showHUDActivity:(UIView *)parentView
{
    UIView *window = (parentView == nil ? [XCMessageHelper getTopWindow] : parentView);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
}

static NSString * currentHUDKey;

+ (void)showHUDActivity:(UIView *)parentView forKey:(NSString *)key
{
    if (!currentHUDKey) {
        currentHUDKey = key;
        [self showHUDActivity:parentView];
    }
}

+ (void)showHUDActivity:(UIView *)parentView hideAfter:(int)time
{
    UIView *window = (parentView == nil ? [XCMessageHelper getTopWindow] : parentView);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XCMessageHelper hideHUDActivity:parentView];
    });
}

+ (void)showHUDActivity:(NSString *)message parentView:(UIView *)parentView
{
    UIView *window = (parentView == nil ? [XCMessageHelper getTopWindow] : parentView);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = message;
    [hud showAnimated:YES];
}

+ (void)hideHUDActivityWithoutAnimation:(UIView *)parentView
{
    UIView *window = (parentView == nil ? [XCMessageHelper getTopWindow] : parentView);
    [MBProgressHUD hideAllHUDsForView:window animated:NO];
}

+ (void)hideHUDActivityWithoutAnimation:(UIView *)parentView forKey:(NSString *)key
{
    if ([currentHUDKey isEqualToString:key]) {
        [self hideHUDActivityWithoutAnimation:parentView];
        currentHUDKey = nil;
    }
}

+ (void)hideHUDActivity:(UIView *)parentView
{
    UIView *window = (parentView == nil ? [XCMessageHelper getTopWindow] : parentView);
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
}

@end
