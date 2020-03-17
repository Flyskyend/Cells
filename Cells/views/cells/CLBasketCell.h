//
//  CLBasketCell.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * kBasketCell = @"kBasketCell";

@class CLBasket;
@interface CLBasketCell : UICollectionViewCell

- (void)updateWithBasket:(CLBasket *)basket;

@end
