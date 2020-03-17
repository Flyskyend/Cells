//
//  CLBoxDetailCell.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBoxDetailCell.h"
#import "CLCell.h"

@interface CLBoxDetailCell ()

@property (nonatomic, strong) CLCell *cell;
@property (nonatomic, strong) UIView *cellView;

@end

@implementation CLBoxDetailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.cellView];
        [self.cellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
        }];
    }
    return self;
}

- (UIView *)cellView {
    if (!_cellView) {
        _cellView = [UIView new];
    }
    return _cellView;
}

- (void)updateWithCell:(CLCell *)cell {
    _cell = cell;
    if (cell) {
        self.cellView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.3];
    } else {
        self.cellView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    }
}

@end
