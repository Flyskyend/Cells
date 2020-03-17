//
//  CLCellsCell.h
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kCellsCell = @"kCellsCell";

@class CLCell;
@interface CLCellsCell : UITableViewCell

- (void)updateWithCell:(CLCell *)cell;

@end
