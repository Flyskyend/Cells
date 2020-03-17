//
//  CLEditBoxViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/12/1.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLBox;
@interface CLEditBoxViewController : UIViewController

- (instancetype)initWithBasketId:(long)bid;
- (instancetype)initWithBox:(CLBox *)box;

@property (nonatomic, copy) void (^createdBox)(CLBox *box);
@property (nonatomic, copy) void (^editedBox)(CLBox *box);
@property (nonatomic, copy) void (^deletedBox)(CLBox *box);
@property (nonatomic, copy) void (^refresh)(BOOL isDelete,NSObject *object);


@end
