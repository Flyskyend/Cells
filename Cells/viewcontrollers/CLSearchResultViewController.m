//
//  CLSearchResultViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/3/25.
//  Updated by 罗劭衡 on 2019/11/24.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLSearchResultViewController.h"

@interface CLSearchResultViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *list;

@end

@implementation CLSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NAV_BAR_HEIGHT, 0, 0, 0));
    }];
    if (@available(iOS 11, *)) {
        self.list.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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

#import "CLCell.h"
#import "CLCanister.h"
#import "CLBox.h"
#import "CLBasket.h"
#import "CLCellsCell.h"
#import "CLEditCellViewController.h"
#import "CLEditBoxViewController.h"
#import "CLEditBasketViewController.h"
#import "CLEditCanisterViewController.h"

@interface CLCellsResultViewController ()

@property (nonatomic, strong) NSMutableArray<CLCell *> *cells;
@property (nonatomic, strong) NSMutableArray<CLBox *> *boxs;
@property (nonatomic, strong) NSMutableArray<CLCanister *> *canisters;
@property (nonatomic, strong) NSMutableArray<CLBasket *> *baskets;
@property (nonatomic, strong) NSMutableArray *Data;
@property (nonatomic, assign) NSInteger Id;

@end

@implementation CLCellsResultViewController

//- (instancetype)initWithCells:(NSArray<CLCell *> *)cells {
//    self = [super init];
//    if (self) {
//        _cells = cells.mutableCopy;
//    }
//    return self;
//}

- (instancetype)initWithId:(NSInteger)Id andData:(NSArray *) Data{
    self = [super init];
    if (self) {
        _Id = Id;
        _Data = Data.mutableCopy;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *SearchName=[NSArray arrayWithObjects:@"液氮罐", @"细胞篮", @"细胞盒", @"细胞", nil];
    self.navigationItem.title = SearchName[_Id];
    [self.list registerClass:[CLCellsCell class] forCellReuseIdentifier:kCellsCell];
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.Data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLCellsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellsCell forIndexPath:indexPath];
    [cell updateWithCell:[self.Data objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLCell *cell = [self.Data objectAtIndex:indexPath.row];
    switch (_Id)
    {
        case 0:
        {
            CLEditCanisterViewController *editVC = [[CLEditCanisterViewController alloc] initWithCanister:(CLCanister *)cell];
            editVC.deletedCanister = ^(CLCanister *canister) {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                [self.Data removeObjectAtIndex:indexPath.row];
                [self.list reloadData];
            };
            editVC.editedCanister = ^(CLCanister *canister) {
                [self.Data replaceObjectAtIndex:indexPath.row withObject:canister];
                [self.list reloadData];
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
            });
            break;
        }
        case 1:
        {
            CLEditBasketViewController *editVC = [[CLEditBasketViewController alloc] initWithBasket:(CLBasket *)cell];
            editVC.deletedBasket = ^(CLBasket *basket) {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                [self.Data removeObjectAtIndex:indexPath.row];
                [self.list reloadData];
            };
            editVC.editedBasket = ^(CLBasket *basket) {
                [self.Data replaceObjectAtIndex:indexPath.row withObject:basket];
                [self.list reloadData];
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
            });
            break;
        }
        case 2:
        {
            CLEditBoxViewController *editVC = [[CLEditBoxViewController alloc] initWithBox:(CLBox *)cell];
            editVC.deletedBox = ^(CLBox *box) {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                [self.Data removeObjectAtIndex:indexPath.row];
                [self.list reloadData];
            };
            editVC.editedBox = ^(CLBox *box) {
                [self.Data replaceObjectAtIndex:indexPath.row withObject:box];
                [self.list reloadData];
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
            });
            break;
        }
        case 3:
        {
            CLEditCellViewController *editVC = [[CLEditCellViewController alloc] initWithCell:cell];
            editVC.deletedCell = ^(CLCell *cell) {
                [self.Data removeObjectAtIndex:indexPath.row];
                [self.list reloadData];
            };
            editVC.editedCell = ^(CLCell *cell) {
                [self.Data replaceObjectAtIndex:indexPath.row withObject:cell];
                [self.list reloadData];
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
            });
            break;
        }
    }
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
