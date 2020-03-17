//
//  CLCellsCell.m
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCellsCell.h"
#import "CLCell.h"

@interface CLCellsCell ()

@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UILabel *timeLb;

@end

@implementation CLCellsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.nameLb];
        [self.contentView addSubview:self.timeLb];
        [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(10);
            make.right.mas_equalTo(self.contentView).offset(-10);
            make.height.mas_equalTo(20);
        }];
        [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.top.equalTo(self.nameLb.mas_bottom).offset(10);
            make.right.mas_equalTo(self.contentView).offset(-10);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (UILabel *)nameLb {
    if (!_nameLb) {
        _nameLb = [[UILabel alloc] init];
        _nameLb.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLb;
}

- (UILabel *)timeLb {
    if (!_timeLb) {
        _timeLb = [[UILabel alloc] init];
        _timeLb.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _timeLb;
}

- (void)updateWithCell:(CLCell *)cell {
    [self.nameLb setAttributedText:[XCGlobal makeAttString:cell.name withFontSize:16]];
    [self.timeLb setAttributedText:[XCGlobal makeAttString:[XCGlobal formatTime:cell.createTime withFormat:@"YYYY-MM-dd HH:mm:ss"]
                                              withFontSize:14
                                                 withColor:[UIColor flatGrayColor]]];
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
