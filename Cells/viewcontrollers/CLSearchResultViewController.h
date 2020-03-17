//
//  CLSearchResultViewController.h
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLSearchResultViewController : UIViewController

@end

@class CLCell;
@interface CLCellsResultViewController : CLSearchResultViewController

//- (instancetype)initWithCells:(NSArray <CLCell *>*)cells;
- (instancetype)initWithId:(NSInteger)Id andData:(NSArray *) Data;

@end
