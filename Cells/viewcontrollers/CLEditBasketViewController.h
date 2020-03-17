//
//  CLEditBasketViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLBasket;
@interface CLEditBasketViewController : UIViewController

- (instancetype)initWithCanisterId:(long)cid;
- (instancetype)initWithBasket:(CLBasket *)basket;

@property (nonatomic, copy) void (^createdBasket)(CLBasket *basket);
@property (nonatomic, copy) void (^editedBasket)(CLBasket *basket);
@property (nonatomic, copy) void (^deletedBasket)(CLBasket *basket);
@property (nonatomic, copy) void (^refresh)(BOOL isDelete,NSObject *object);

@end
