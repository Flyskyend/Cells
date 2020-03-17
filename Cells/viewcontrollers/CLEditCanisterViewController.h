//
//  CLEditCanisterViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLCanister;
@interface CLEditCanisterViewController : UIViewController

- (instancetype)initWithCanister:(CLCanister *)canister;

@property (nonatomic, copy) void (^createdCanister)(CLCanister *canister);
@property (nonatomic, copy) void (^editedCanister)(CLCanister *canister);
@property (nonatomic, copy) void (^deletedCanister)(CLCanister *canister);
@property (nonatomic, copy) void (^refresh)(BOOL isDelete,NSObject *object);

@end
