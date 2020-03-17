//
//  CLBoxListCell.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBox.h"
#import "CLBoxListCell.h"

@interface CLBoxListCell()

@property (nonatomic, strong) CLBox *box;
@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UILabel *countLb;

@end

@implementation CLBoxListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *contentView = [UIView new];
        contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:contentView];
        [contentView addSubview:self.nameLb];
        [contentView addSubview:self.countLb];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
        }];
        [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(contentView);
            make.bottom.equalTo(contentView.mas_centerY);
        }];
        [self.countLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(contentView);
            make.top.equalTo(self.nameLb.mas_bottom);
        }];
    }
    return self;
}

- (UILabel *)nameLb {
    if (!_nameLb) {
        _nameLb = [[UILabel alloc] init];
        _nameLb.numberOfLines = 0;
        _nameLb.font = [XCFont lightFontWithSize:15];
        _nameLb.textAlignment = NSTextAlignmentCenter;
        _nameLb.textColor = [UIColor lightGrayColor];
    }
    return _nameLb;
}

- (UILabel *)countLb {
    if (!_countLb) {
        _countLb = [[UILabel alloc] init];
        _countLb.numberOfLines = 0;
        _countLb.font = [XCFont lightFontWithSize:15];
        _countLb.textAlignment = NSTextAlignmentCenter;
        _countLb.textColor = [UIColor lightGrayColor];
    }
    return _countLb;
}

- (void)updateWithBox:(CLBox *)box {
    _box = box;
    self.nameLb.text = box.name;
    self.countLb.text = [NSString stringWithFormat:@"%@ x %@", @(box.row), @(box.column)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
