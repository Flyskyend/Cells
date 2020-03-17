//
//  CLRedirect.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLRedirect.h"
#import "CLAppDelegate.h"

@implementation CLRedirect

SYNTHESIZE_SINGLETON_FOR_CLASS(CLRedirect);

- (void)pushViewController:(UIViewController *)viewController {
    if ([[AppDelegate window].rootViewController isKindOfClass:UINavigationController.class]) {
        [((UINavigationController *)[AppDelegate window].rootViewController) pushViewController:viewController animated:YES];
    }
}

- (void)popViewController {
    if ([[AppDelegate window].rootViewController isKindOfClass:UINavigationController.class]) {
        [((UINavigationController *)[AppDelegate window].rootViewController) popViewControllerAnimated:YES];
    }
}

- (void)presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController completion:nil];
}

- (void)presentViewController:(UIViewController *)viewController completion:(void (^)())completion {
    [[AppDelegate window].rootViewController presentViewController:viewController animated:YES completion:completion];
}

- (void)dismissViewController {
    [[AppDelegate window].rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

