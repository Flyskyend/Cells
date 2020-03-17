//
//  CLBoxDetailCell.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kBoxDetailCell = @"kBoxDetailCell";

@class CLCell;
@interface CLBoxDetailCell : UICollectionViewCell

- (void)updateWithCell:(CLCell *)cell;

@end
