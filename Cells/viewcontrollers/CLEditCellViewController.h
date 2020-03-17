//
//  CLEditCellViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/1/15.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLCell;
@interface CLEditCellViewController : UIViewController

- (instancetype)initWithCell:(CLCell *)cell;

@property (nonatomic, copy) void (^createdCell)(CLCell *cell);
@property (nonatomic, copy) void (^editedCell)(CLCell *cell);
@property (nonatomic, copy) void (^deletedCell)(CLCell *cell);
@property (nonatomic, copy) void (^refresh)(BOOL isDelete,NSObject *object);

@end
