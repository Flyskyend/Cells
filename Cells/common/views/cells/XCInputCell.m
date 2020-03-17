//
//  XCInputCell.m
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "XCInputCell.h"

@implementation XCInputCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    //NSLog(@"%@",reuseIdentifier);
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        if([self.reuseIdentifier isEqualToString:@"kTextView"])
        {
            [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).with.offset(35);
                make.centerY.equalTo(self.contentView);
                make.width.mas_lessThanOrEqualTo(100);
            }];
        }
        else if([self.reuseIdentifier isEqualToString:@"kTextView_create"])
        {
            [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).with.offset(15);
                make.centerY.equalTo(self.contentView);
                make.width.mas_lessThanOrEqualTo(100);
            }];
        }
        else
        {
            [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).with.offset(15);
                make.centerY.equalTo(self.contentView);
                make.width.mas_lessThanOrEqualTo(100);
            }];
        }
        
        if([self.reuseIdentifier isEqualToString:@"kInputCell"])
        {
            //NSLog(@"\nkInputCell---------\n");
            [self.input mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.titleLb.mas_right).with.offset(5);
                make.right.equalTo(self.contentView).with.offset(-10);
                make.top.equalTo(self.contentView).with.offset(10);
                make.bottom.equalTo(self.contentView).with.offset(-10);
            }];
        }
        else if([self.reuseIdentifier isEqualToString:@"kInputCell_N"])
        {
            //NSLog(@"\nkInputCell_N--------\n");
            [self.input mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.titleLb.mas_right).with.offset(5);
                make.right.equalTo(self.contentView).with.offset(-10);
                make.top.equalTo(self.contentView).with.offset(10);
                make.bottom.equalTo(self.contentView).with.offset(-10);
            
            }];
            [_input setEnabled:NO];
        }
        else if([self.reuseIdentifier isEqualToString:@"kTextView"])
        {
            //NSLog(@"\nkTextView--------\n");
            [self.textview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.titleLb.mas_right).with.offset(35);
                make.right.equalTo(self.contentView).with.offset(-10);
                make.top.equalTo(self.contentView).with.offset(15);
                make.bottom.equalTo(self.contentView).with.offset(-15);
            }];
            [_textview setEditable:NO];
        }
        else if([self.reuseIdentifier isEqualToString:@"kTextView_create"])
        {
            [self.textview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.titleLb.mas_right).with.offset(20);
                make.right.equalTo(self.contentView).with.offset(-10);
                make.top.equalTo(self.contentView).with.offset(15);
                make.bottom.equalTo(self.contentView).with.offset(-15);
            }];
        }
        else
        {
            //NSLog(@"\nelse--------\n");
            [self.input mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.titleLb.mas_right).with.offset(5);
                make.right.equalTo(self.contentView).with.offset(-10);
                make.top.equalTo(self.contentView).with.offset(10);
                make.bottom.equalTo(self.contentView).with.offset(-10);
            }];
        }
    }
    return self;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLb.numberOfLines = 0;
        [self.contentView addSubview:_titleLb];
    }
    return _titleLb;
}

- (UITextField *)input {
    if (!_input) {
        _input = [[UITextField alloc] init];
        //NSLog(@"\ninput alloc--------\n");
        _input.translatesAutoresizingMaskIntoConstraints = NO;
        _input.font = [XCFont lightFontWithSize:15];
        _input.textAlignment = NSTextAlignmentRight;
        //if(![self.reuseIdentifier isEqualToString:@"kTextView"])
            [self.contentView addSubview:_input];
    }
    return _input;
}

- (UITextView *)textview {
    if (!_textview) {
        _textview = [[UITextView alloc] init];
        //NSLog(@"\ntextview alloc--------\n");
        _textview.translatesAutoresizingMaskIntoConstraints = NO;
        _textview.font = [XCFont lightFontWithSize:15];
        _textview.textAlignment = NSTextAlignmentLeft;
        _textview.layer.borderWidth = 0.4;
        [self.contentView addSubview:_textview];
    }
    return _textview;
}

- (void)focus {
    if(![self.reuseIdentifier isEqualToString:@"kTextView"])
        [self.input becomeFirstResponder];
    else
        [self.textview becomeFirstResponder];
}

- (void)unFocus {
    if(![self.reuseIdentifier isEqualToString:@"kTextView"])
        [self.input resignFirstResponder];
    else
        [self.textview resignFirstResponder];
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
