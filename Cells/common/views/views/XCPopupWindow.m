//
//  XCPopupWindow.m
//  XCZhibo
//
//  Created by 王新晨 on 2017/10/20.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import "XCPopupWindow.h"

@implementation UIViewController (XCPopupWindow)

- (void)xc_dismiss:(void (^)())finishBlock {
    [[self mz_formSheetPresentedPresentationController] dismissViewControllerAnimated:YES completion:finishBlock];
}

- (void)xc_showSheetFormWithController:(UIViewController *)vc height:(CGFloat)height {
    [self xc_showSheetFormWithController:vc height:height shouldDismissOnBackgroundViewTap:YES];
}

- (void)xc_showSheetFormWithController:(UIViewController *)vc height:(CGFloat)height shouldDismissOnBackgroundViewTap:(BOOL)should {
    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:vc];
    formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyleSlideFromBottom;
    formSheetController.presentationController.shouldDismissOnBackgroundViewTap = should;
    formSheetController.presentationController.shouldApplyBackgroundBlurEffect = YES;
    formSheetController.presentationController.contentViewSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
    formSheetController.presentationController.portraitTopInset = [[UIScreen mainScreen] bounds].size.height - height;
    [self presentViewController:formSheetController animated:YES completion:nil];
}

- (void)xc_showPopFormWithController:(UIViewController *)vc inRect:(CGSize)size {
    [self xc_showPopFormWithController:vc inRect:size shouldDismissOnBackgroundViewTap:YES];
}

- (void)xc_showPopFormWithController:(UIViewController *)vc inRect:(CGSize)size shouldDismissOnBackgroundViewTap:(BOOL)should {
    [self xc_showPopFormWithController:vc inRect:size shouldDismissOnBackgroundViewTap:should usingStyle:MZFormSheetPresentationTransitionStyleBounce];
}

- (void)xc_showPopFormWithController:(UIViewController *)vc inRect:(CGSize)size shouldDismissOnBackgroundViewTap:(BOOL)should usingStyle:(MZFormSheetPresentationTransitionStyle)style {
    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:vc];
    formSheetController.contentViewControllerTransitionStyle = style;
    formSheetController.presentationController.shouldDismissOnBackgroundViewTap = should;
    formSheetController.presentationController.shouldApplyBackgroundBlurEffect = YES;
    formSheetController.presentationController.contentViewSize = size;
    [self presentViewController:formSheetController animated:YES completion:nil];
}

@end
