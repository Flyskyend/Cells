//
//  XCPickTimeViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "XCPickTimeViewController.h"
#import "XCPopupWindow.h"

@interface XCPickTimeViewController ()

@property (nonatomic, strong) UIDatePicker *picker;
@property (nonatomic, assign) NSTimeInterval time;

@end

@implementation XCPickTimeViewController

- (instancetype)initWithTime:(NSTimeInterval)time {
    self =  [super init];
    if (self) {
        _time = time;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.datePickerMode = UIDatePickerModeDate;
    if (self.time > 0) {
        [picker setDate:[NSDate dateWithTimeIntervalSince1970:self.time]];
    }
    [self.view addSubview:picker];
    [picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.picker = picker;
}

- (IBAction)cancel:(id)sender {
    if ([self.deleagate respondsToSelector:@selector(dismiss)]) {
        [self.deleagate dismiss];
    }
}

- (IBAction)done:(id)sender {
    if ([self.deleagate respondsToSelector:@selector(finish:)]) {
        [self.deleagate finish:[self.picker.date timeIntervalSince1970]];
    }
    [self cancel:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
