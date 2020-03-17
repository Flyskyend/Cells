//
//  CLCanisterCell.h
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kCanisterCell = @"kCanisterCell";

@class CLCanister;
@interface CLCanisterCell : UICollectionViewCell

- (void)updateWithCanister:(CLCanister *)canister;

@end
