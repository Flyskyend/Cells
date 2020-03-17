//
//  CLCanisterDetailViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBasket.h"
#import "CLBasketDB.h"
#import "CLCanister.h"
#import "CLEditBasketViewController.h"
#import "CLCanisterDetailViewController.h"
#import "NSDictionary+XCDBQuery.h"

@interface CLCanisterDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CLCanister *canister;
@property (nonatomic, strong) UITableView *list;
@property (nonatomic, strong) NSMutableArray *baskets;

@end

@implementation CLCanisterDetailViewController

- (instancetype)initWithCanister:(CLCanister *)canister {
    self = [super init];
    if (self) {
        _canister = canister;
        _baskets = @[].mutableCopy;
    }
    return self;
}

- (UITableView *)list {
    if (!_list) {
        _list = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _list.delegate = self;
        _list.dataSource = self;
        _list.showsVerticalScrollIndicator = NO;
        _list.estimatedRowHeight = 0;
        _list.estimatedSectionFooterHeight = 0;
        _list.estimatedSectionHeaderHeight = 0;
    }
    return _list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.canister.name;
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createBasket:)];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (IBAction)createBasket:(id)sender {
    CLEditBasketViewController *editVC = [[CLEditBasketViewController alloc] init];
    editVC.createdBasket = ^(CLBasket *basket) {
        [self.baskets addObject:basket];
        [self.list reloadData];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
}

- (void)loadBaskets {
    [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{
        kDBAndCond: @[@"canister_id=:canister_id"],
        kDBAndValue: @{ @"canister_id": @(self.canister.cid) }
    }
    finishBlock:^(NSArray<CLBasket *> *baskets) {
        self.baskets = [baskets mutableCopy];
        [self.list reloadData];
    }];
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.baskets.count;
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
