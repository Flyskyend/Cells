//
//  CLSearchContentViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/3/24.
//  Updated by 罗劭衡 on 2019/2/20.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLSearchContentViewController.h"
#import "XCInputCell.h"
#import "XCPickTimeRangeCell.h"
#import "XCPickTimeViewController.h"
#import "XCPopupWindow.h"
#import <XCMessageHelper/XCMessageHelper.h>
#import "NSDictionary+XCDBQuery.h"

@interface CLSearchContentViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *list;
@property (nonatomic, strong) UIButton *searchBtn;

- (IBAction)search:(id)sender;

@end

@implementation CLSearchContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        if(@available(iOS 11.0,*))
        {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(0);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(0);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(0);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(0);
        }
        else
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 40, 0));
    }];
    if (@available(iOS 11, *)) {
        self.list.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setAttributedTitle:[XCGlobal makeAttString:@"搜索" withFontSize:18 withColor:[UIColor whiteColor]]
                         forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[[UIColor flatGreenColor] image] forState:UIControlStateNormal];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    [searchBtn addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    self.searchBtn = searchBtn;
}

- (UITableView *)list {
    if (!_list) {
        _list = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _list.delegate = self;
        _list.dataSource = self;
        _list.estimatedSectionFooterHeight = 0;
        _list.estimatedSectionHeaderHeight = 0;
        _list.estimatedRowHeight = 0;
        _list.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _list;
}



#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01;
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

#import "CLCellDB.h"
#import "CLBoxDB.h"
#import "CLBasketDB.h"
#import "CLCanisterDB.h"
#import "CLSearchResultViewController.h"

@interface CLSearchCellsViewController () <XCPickTimeDelegate, UITextFieldDelegate>

@property (nonatomic, strong) XCInputCell *nameCell;
@property (nonatomic, strong) XCPickTimeRangeCell *timeCell;
@property (nonatomic, assign) BOOL pickStart;
@property (nonatomic, assign) NSInteger Id;

@end

@implementation CLSearchCellsViewController

- (instancetype)initWithId:(NSInteger)Id
{
    self = [super init];
    if (self) {
        _Id = Id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (XCInputCell *)nameCell {
    if (!_nameCell) {
        NSArray *SearchName=[NSArray arrayWithObjects:@"液氮罐", @"细胞篮", @"细胞盒", @"细胞", nil];
        _nameCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"name"];
        //NSLog(@"use %d %@",_Id,SearchName[_Id]);
        _nameCell.titleLb.text = [NSString stringWithFormat:@"%@名称",SearchName[_Id]];
        _nameCell.input.placeholder = [NSString stringWithFormat:@"输入%@名称，支持模糊搜索",SearchName[_Id]];
        _nameCell.input.returnKeyType = UIReturnKeySearch;
        _nameCell.input.delegate = self;
    }
    return _nameCell;
}

- (XCPickTimeRangeCell *)timeCell {
    if (!_timeCell) {
        _timeCell = [[XCPickTimeRangeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPickTimeRangeCell];
        _timeCell.titleLb.text = @"创建时间";
        [_timeCell.startBtn addTarget:self action:@selector(pickTime:) forControlEvents:UIControlEventTouchUpInside];
        [_timeCell.endBtn addTarget:self action:@selector(pickTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeCell;
}

- (IBAction)pickTime:(id)sender {
    self.pickStart = sender == self.timeCell.startBtn;
    XCPickTimeViewController *pickVC =
    [[XCPickTimeViewController alloc] initWithTime:self.pickStart ? self.timeCell.start : self.timeCell.end];
    pickVC.deleagate = self;
    UINavigationController *pickNav = [[UINavigationController alloc] initWithRootViewController:pickVC];
    [self xc_showSheetFormWithController:pickNav height:300.f shouldDismissOnBackgroundViewTap:YES];
}

- (void)search:(id)sender {
//    BOOL empty = self.nameCell.input.text.length == 0 && self.timeCell.start == 0 && self.timeCell.end == 0;
//    if (empty) {
//        return [XCMessageHelper showHUDMessage:@"请输入查询条件"];
//    }
//    self.searchBtn.enabled = NO;
    NSMutableArray *conds = @[].mutableCopy;
    NSMutableDictionary *values = @{}.mutableCopy;
    if (self.nameCell.input.text.length > 0) {
        [conds addObject:@"name LIKE :name"];
        [values setObject:[NSString stringWithFormat:@"%%%@%%", self.nameCell.input.text] forKey:@"name"];
    }
    if (self.timeCell.start > 0 && self.timeCell.end > 0) {
        [conds addObject:@"create_time BETWEEN :min AND :max"];
        [values setObject:@(self.timeCell.end) forKey:@"max"];
        [values setObject:@(self.timeCell.start) forKey:@"min"];
    } else if (self.timeCell.start > 0) {
        [conds addObject:@"create_time >= :min"];
        [values setObject:@(self.timeCell.start) forKey:@"min"];
    } else if (self.timeCell.end > 0) {
        [conds addObject:@"create_time <= :max"];
        [values setObject:@(self.timeCell.end) forKey:@"max"];
    }
    
    switch (_Id) {
        case 0:
        {
            [[CLCanisterDB sharedCLCanisterDB] getCanistersWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLCanisterDB *> *canisters) {
                self.searchBtn.enabled = YES;
                CLCellsResultViewController *canistersVC = [[CLCellsResultViewController alloc] initWithId:_Id andData:canisters];
                [self.navigationController pushViewController:canistersVC animated:YES];
            }];
            return;
        }
        case 1:
        {
            [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLBasket *> *baskets) {
                self.searchBtn.enabled = YES;
                CLCellsResultViewController *basketsVC = [[CLCellsResultViewController alloc] initWithId:_Id andData:baskets];
                [self.navigationController pushViewController:basketsVC animated:YES];
            }];
            return;
        }
        case 2:
        {
            [[CLBoxDB sharedCLBoxDB] getBoxsWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLBox *> *boxs) {
                self.searchBtn.enabled = YES;
                CLCellsResultViewController *boxsVC = [[CLCellsResultViewController alloc] initWithId:_Id andData:boxs];
                [self.navigationController pushViewController:boxsVC animated:YES];
            }];
            return;
        }
        case 3:
        {
            [[CLCellDB sharedCLCellDB] getCellsWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLCell *> *cells) {
                self.searchBtn.enabled = YES;
                CLCellsResultViewController *cellsVC = [[CLCellsResultViewController alloc] initWithId:_Id andData:cells];
                [self.navigationController pushViewController:cellsVC animated:YES];
            }];
            return;
        }
        default:
            return;
    }
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return self.nameCell;
        case 1:
            return self.timeCell;
        default:
            return [UITableViewCell new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01;
}

#pragma mark - XCPickTimeDelegate

- (void)dismiss {
    [self xc_dismiss:nil];
}

- (void)finish:(NSTimeInterval)time {
    if (self.pickStart) {
        self.timeCell.start = time;
    } else {
        self.timeCell.end = time;
    }
    [self xc_dismiss:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search:nil];
    return YES;
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
