//
//  CLBasketCell.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBasket.h"
#import "CLBasketCell.h"
#import "CLBoxDetailViewController.h"
#import "CLBoxListCell.h"
#import "CLBoxDB.h"
#import "CLBox.h"
#import "CLCanister.h"
#import "CLEditBoxViewController.h"
#import "CLRedirect.h"
#import "NSDictionary+XCDBQuery.h"

@interface CLBasketCell() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *list;
@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) CLBasket *basket;
@property (nonatomic, strong) CLCanister *canister;
@property (nonatomic, strong) NSMutableArray *boxs;

@end

@implementation CLBasketCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _boxs = @[].mutableCopy;
        [self.contentView addSubview:self.list];
        [self.contentView addSubview:self.nameLb];
        [self.contentView addSubview:self.addButton];
        [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(40, 0, 40, 0));
        }];
        [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(40);
        }];
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(40);
        }];
    }
    return self;
}

- (UITableView *)list {
    if (!_list
        ) {
        _list
        = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _list.delegate = self;
        _list.dataSource = self;
        _list.estimatedRowHeight = 0;
        _list.estimatedSectionFooterHeight = 0;
        _list.estimatedSectionHeaderHeight = 0;
        _list.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_list registerClass:[CLBoxListCell class] forCellReuseIdentifier:kCLBoxListCell];
    }
    return _list;
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

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:@"加一盒" forState:UIControlStateNormal];
        _addButton.titleLabel.font = [XCFont lightFontWithSize:16];
        [_addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addBox:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (IBAction)addBox:(id)sender {
    CLEditBoxViewController *editVC = [[CLEditBoxViewController alloc] initWithBasketId:self.basket.bid];
    editVC.createdBox = ^(CLBox *box) {
        [self.boxs addObject:box];
        [self.list reloadData];
    };
    editVC.deletedBox = ^(CLBox *box) {
        [self.boxs removeObject:box];
        [self.list reloadData];
    };
//    editVC.editedBox = ^(CLBox *box) {
//        [self.boxs replaceObjectAtIndex:[self.boxs indexOfObject:box] withObject:box];
//        [self.list reloadData];
//    };
    [[CLRedirect sharedCLRedirect] presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC]];
}

- (void)updateWithBasket:(CLBasket *)basket {
    _basket = basket;
    self.nameLb.text = basket.name;
    [[CLBoxDB sharedCLBoxDB] getBoxsWithCond:@{
        kDBAndCond: @[@"basket_id=:basket_id"],
        kDBAndValue: @{ @"basket_id": @(self.basket.bid) }
    }
    finishBlock:^(NSArray<CLBox *> *boxs) {
        self.boxs = [boxs mutableCopy];
        [self.list reloadData];
    }];
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.boxs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLBoxListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCLBoxListCell forIndexPath:indexPath];
    [cell updateWithBox:[self.boxs objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLBoxDetailViewController *detailVC = [[CLBoxDetailViewController alloc] initWithBox:[self.boxs objectAtIndex:indexPath.row]];
    [[CLRedirect sharedCLRedirect] pushViewController:detailVC];
}

@end
