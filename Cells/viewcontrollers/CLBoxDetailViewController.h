//
//  CLBoxDetailViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLBox;
@interface CLBoxDetailViewController : UIViewController

- (instancetype)initWithBox:(CLBox *)box;
@property (nonatomic, copy) void (^refresh)(BOOL isDelete,NSObject *object);

@end
