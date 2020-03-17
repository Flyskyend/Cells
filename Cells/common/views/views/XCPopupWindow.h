//
//  XCPopupWindow.h
//  XCZhibo
//
//  Created by 王新晨 on 2017/10/20.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MZFormSheetPresentationController/MZFormSheetPresentationViewController.h>

@interface UIViewController (XCPopupWindow)

- (void)xc_dismiss:(void(^)())finishBlock;
- (void)xc_showSheetFormWithController:(UIViewController *)vc height:(CGFloat)height;
- (void)xc_showSheetFormWithController:(UIViewController *)vc height:(CGFloat)height shouldDismissOnBackgroundViewTap:(BOOL)should;
- (void)xc_showPopFormWithController:(UIViewController *)vc inRect:(CGSize)size;
- (void)xc_showPopFormWithController:(UIViewController *)vc inRect:(CGSize)size shouldDismissOnBackgroundViewTap:(BOOL)should;
- (void)xc_showPopFormWithController:(UIViewController *)vc inRect:(CGSize)size shouldDismissOnBackgroundViewTap:(BOOL)should usingStyle:(MZFormSheetPresentationTransitionStyle)style;

@end
