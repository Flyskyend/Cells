//
//  XCInputCell.h
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Updated by 罗劭衡 on 2019/11/12
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const kInputCell = @"kInputCell";
static NSString* const kInputCell_N = @"kInputCell_N";
static NSString* const kTextView = @"kTextView";
static NSString* const kTextView_create = @"kTextView_create";
static NSString* const kInputWithOffsetCell = @"kInputWithOffset";

@interface XCInputCell : UITableViewCell <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) UILabel *titleLb;
@property (nonatomic, strong) UITextField *input;
@property (nonatomic, strong) UITextView *textview;
@property (nonatomic, strong) UILabel *text;


- (void)focus;
- (void)unFocus;

@end
