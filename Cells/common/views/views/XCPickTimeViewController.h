//
//  XCPickTimeViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XCPickTimeDelegate <NSObject>

- (void)dismiss;
- (void)finish:(NSTimeInterval)time;

@end

@interface XCPickTimeViewController : UIViewController

- (instancetype)initWithTime:(NSTimeInterval)time;

@property (nonatomic, weak) id <XCPickTimeDelegate> deleagate;

@end
