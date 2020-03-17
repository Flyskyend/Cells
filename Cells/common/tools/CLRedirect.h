//
//  CLRedirect.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLRedirect : NSObject

SYNTHESIZE_SINGLETON_FOR_HEADER(CLRedirect);

- (void)pushViewController:(UIViewController *)viewController;
- (void)popViewController;
- (void)presentViewController:(UIViewController *)viewController;
- (void)presentViewController:(UIViewController *)viewController completion:(void (^)())completion;
- (void)dismissViewController;

@end
