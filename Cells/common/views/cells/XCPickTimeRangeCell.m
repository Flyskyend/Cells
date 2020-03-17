//
//  XCPickTimeRangeCell.m
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "XCPickTimeRangeCell.h"

@interface XCPickTimeRangeCell()

@end

@implementation XCPickTimeRangeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLb];
        [self.contentView addSubview:self.endBtn];
        [self.endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(100, 40));
        }];
        UILabel *label = [UILabel new];
        [self.contentView addSubview:label];
        label.text = @"至";
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.endBtn.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [self.contentView addSubview:self.startBtn];
        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(label.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(100, 40));
        }];
        [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(15);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.startBtn.mas_left).offset(-10);
        }];
        [self.startBtn setAttributedTitle:[XCGlobal makeAttString:@"选择开始时间" withFont:[XCFont lightFontWithSize:14] withColor:[UIColor flatGrayColor]] forState:UIControlStateNormal];
        [self.endBtn setAttributedTitle:[XCGlobal makeAttString:@"选择结束时间" withFont:[XCFont lightFontWithSize:14] withColor:[UIColor flatGrayColor]] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setStart:(NSTimeInterval)start {
    _start = start;
    [self.startBtn setAttributedTitle:[XCGlobal makeAttString:[XCGlobal formatTime:start withFormat:@"YYYY-MM-dd"]
                                                     withFont:[XCFont lightFontWithSize:15]]
                             forState:UIControlStateNormal];
}

- (void)setEnd:(NSTimeInterval)end {
    _end = end;
    [self.endBtn setAttributedTitle:[XCGlobal makeAttString:[XCGlobal formatTime:end withFormat:@"YYYY-MM-dd"]
                                                   withFont:[XCFont lightFontWithSize:15]]
                           forState:UIControlStateNormal];
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLb.numberOfLines = 0;
    }
    return _titleLb;
}

- (UIButton *)endBtn {
    if (!_endBtn) {
        _endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _endBtn;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _startBtn;
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
