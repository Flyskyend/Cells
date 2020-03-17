//
//  CLEditCellViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/15.
//  Updated by 罗劭衡 on 2019/10/22.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCell.h"
#import "CLCellDB.h"
#import "CLBox.h"
#import "CLBoxDB.h"
#import "CLBasket.h"
#import "CLBasketDB.h"
#import "CLCanister.h"
#import "CLCanisterDB.h"
#import "CLEditCellViewController.h"
#import "CLEditBoxViewController.h"
#import "CLEditBasketViewController.h"
#import "CLEditCanisterViewController.h"
#import "XCInputCell.h"
#import <XCMessageHelper/XCMessageHelper.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>
#import "NSDictionary+XCDBQuery.h"

@interface CLEditCellViewController ()  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *list;
@property (nonatomic, strong) XCInputCell *nameCell;
@property (nonatomic, strong) XCInputCell *idCell;
@property (nonatomic, strong) XCInputCell *boxInfoCell;
@property (nonatomic, strong) XCInputCell *basketInfoCell;
@property (nonatomic, strong) XCInputCell *canisterInfoCell;
@property (nonatomic, strong) XCInputCell *createTimeCell;
@property (nonatomic, strong) XCInputCell *boxIndexCell;
@property (nonatomic, strong) XCInputCell *noteCell;
@property (nonatomic, strong) CLCell *cell;
@property (nonatomic, assign) BOOL createCell;
@property (nonatomic, strong) NSMutableArray<CLBox *> *box;
@property (nonatomic, strong) NSMutableArray<CLBasket *> *basket;
@property (nonatomic, strong) NSMutableArray<CLCanister *> *canister;
@property (nonatomic, strong) UIButton *delete;


@end

@implementation CLEditCellViewController

- (instancetype)initWithCell:(CLCell *)cell {
    self = [super init];
    if (self) {
        _cell = cell;
        _createCell = cell.cellId == 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.createCell ? @"创建细胞" : @"细胞信息";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createCell ? @"取消":@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createCell ? @"创建" : @"修改" style:UIBarButtonItemStylePlain target:self action:self.createCell ? @selector(confirm:) : @selector(modify:)];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    self.list.rowHeight=UITableViewAutomaticDimension;
//    self.list.estimatedRowHeight=100.0f;
    
    if (!self.createCell) {
        [self loadData];
    } else {
        [self.nameCell focus];
    }
}

- (UITableView *)list {
    if (!_list) {
        _list = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _list.delegate = self;
        _list.dataSource = self;
        _list.showsHorizontalScrollIndicator = NO;
        _list.estimatedSectionFooterHeight = 0;
        _list.estimatedSectionHeaderHeight = 0;
        _list.estimatedRowHeight = 0;
        _list.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _list;
}

- (XCInputCell *)nameCell {
    if (!_nameCell) {
        _nameCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createCell? kInputCell:kInputCell_N];
        _nameCell.titleLb.attributedText = [XCGlobal makeAttString:@"名称" withFontSize:15];
    }
    return _nameCell;
}

- (XCInputCell *)noteCell {
    if (!_noteCell) {
        _noteCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: self.createCell? kTextView_create : kTextView];
        _noteCell.titleLb.attributedText = [XCGlobal makeAttString:@"备注" withFontSize:15];
    }
    return _noteCell;
}

- (XCInputCell *)idCell {
    if (!_idCell) {
        _idCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _idCell.titleLb.attributedText = [XCGlobal makeAttString:@"ID" withFontSize:15];
    }
    return _idCell;
}

- (XCInputCell *)boxInfoCell {
    if (!_boxInfoCell) {
        _boxInfoCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _boxInfoCell.titleLb.attributedText = [XCGlobal makeAttString:@"所在细胞盒" withFontSize:15];
        _boxInfoCell.accessoryType=UITableViewCellAccessoryDetailButton;
    }
    return _boxInfoCell;
}

- (XCInputCell *)basketInfoCell {
    if (!_basketInfoCell) {
        _basketInfoCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _basketInfoCell.titleLb.attributedText = [XCGlobal makeAttString:@"所在细胞篮" withFontSize:15];
        _basketInfoCell.accessoryType=UITableViewCellAccessoryDetailButton;
    }
    return _basketInfoCell;
}

- (XCInputCell *)canisterInfoCell {
    if (!_canisterInfoCell) {
        _canisterInfoCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _canisterInfoCell.titleLb.attributedText = [XCGlobal makeAttString:@"所在液氮罐" withFontSize:15];
        _canisterInfoCell.accessoryType=UITableViewCellAccessoryDetailButton;
    }
    return _canisterInfoCell;
}

- (XCInputCell *)createTimeCell {
    if (!_createTimeCell) {
        _createTimeCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _createTimeCell.titleLb.attributedText = [XCGlobal makeAttString:@"创建日期" withFontSize:15];
    }
    return _createTimeCell;
}

- (XCInputCell *)boxIndexCell {
    if (!_boxIndexCell) {
        _boxIndexCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _boxIndexCell.titleLb.attributedText = [XCGlobal makeAttString:@"细胞位置" withFontSize:15];
    }
    return _boxIndexCell;
}

- (void)loadData
{
    [self.nameCell.input setText:self.cell.name];
    [self.idCell.input setText:[NSString stringWithFormat:@"%ld",self.cell.cellId]];
    [self.noteCell.textview setText:[NSString stringWithFormat:@"%@",self.cell.note]];
    [self.createTimeCell.input setText:[XCGlobal formatTime:self.cell.createTime withFormat:@"YYYY-MM-dd HH:mm:ss"]];
    
    [[CLBoxDB sharedCLBoxDB] getBoxsWithCond:@{
        kDBAndCond: @[@"bid=:bid"],
        kDBAndValue: @{ @"bid": @(self.cell.boxId) }
    }
    finishBlock:^(NSArray<CLBox *> *box) {
        self.box = [box mutableCopy];
        [self.boxIndexCell.input setText:[NSString stringWithFormat:@"[%d-%d]",self.cell.boxIndex/self.box.firstObject.column,self.cell.boxIndex%self.box.firstObject.column+1]];
        //NSLog(@"\n---------box:%lu %@",self.box.count,self.box.firstObject);
        [self.boxInfoCell.input setText:[NSString stringWithFormat:@"%@",self.box.firstObject.name]];
        
        [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{
            kDBAndCond: @[@"bid=:bid"],
            kDBAndValue: @{ @"bid": @(self.box.firstObject.basketId) }
        }
        finishBlock:^(NSArray<CLBasket *> *basket) {
            self.basket = [basket mutableCopy];
            //NSLog(@"\n---------basket:%lu %@",self.basket.count,self.basket.firstObject);
            [self.basketInfoCell.input setText:[NSString stringWithFormat:@"%@",self.basket.firstObject.name]];
            [[CLCanisterDB sharedCLCanisterDB] getCanistersWithCond:@{
                kDBAndCond: @[@"cid=:cid"],
                kDBAndValue: @{ @"cid": @(self.basket.firstObject.canisterId) }
            }
            finishBlock:^(NSArray<CLCanister *> *canister) {
                self.canister = [canister mutableCopy];
                //NSLog(@"\n---------canister:%lu %@",self.canister.count,self.canister.firstObject);
                [self.canisterInfoCell.input setText:[NSString stringWithFormat:@"%@",self.canister.firstObject.name]];
            }];
        }];
        
    }];
}

- (void)backToInfo
{
    self.navigationItem.title=@"细胞信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modify:)];
    self.navigationItem.leftBarButtonItem.title = @"返回";
    [self.nameCell.input setEnabled:NO];
    [self.noteCell.textview setEditable:NO];
    [_delete removeFromSuperview];
}

- (IBAction)cancel:(id)sender {
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"保存"])
    {
        [self loadData];
        [self backToInfo];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)modify:(id)sender {
    self.navigationItem.title=@"修改细胞信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    self.navigationItem.leftBarButtonItem.title = @"取消";
    
    [self.nameCell.input setEnabled:YES];
    [self.noteCell.textview setEditable:YES];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete setTitle:@"删除" forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    [delete setBackgroundImage:[[UIColor flatRedColor] image] forState:UIControlStateNormal];
    [self.view addSubview:delete];
    [delete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    self.delete = delete;
}

- (IBAction)confirm:(id)sender {
    [self.nameCell unFocus];
    
    if (!self.nameCell.input.text.length) {
        return [XCMessageHelper showHUDMessage:@"名称不能为空"];
    }
    self.cell.name = self.nameCell.input.text;
    self.cell.note = self.noteCell.textview.text;
    if (self.createCell) {
        self.cell.createTime = [XCGlobal now];
        [[CLCellDB sharedCLCellDB] cacheCell:self.cell withFinishBlock:^(long long lastId) {
            self.cell.cellId = lastId;
            if (self.createdCell) {
                self.createdCell(self.cell);
            }
            [self cancel:nil];
        }];
    } else {
        [[CLCellDB sharedCLCellDB] editCell:self.cell withFinishBlock:^(long long lastId) {
            if (self.editedCell) {
                self.editedCell(self.cell);
            }
            [self backToInfo];
            //[self cancel:nil];
        }];
    }
}

- (IBAction) delete:(id)sender {
    [UIAlertController
    showAlertInViewController:self
                    withTitle:@"将删除细胞及其全部信息，是否确认删除"
                      message:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:@"删除"
            otherButtonTitles:nil
                     tapBlock:^(UIAlertController *_Nonnull controller, UIAlertAction *_Nonnull action, NSInteger buttonIndex) {
                         if (buttonIndex == controller.destructiveButtonIndex) {
                             [[[CLCellDB sharedCLCellDB] deleteCell:self.cell] continueWithBlock:^id _Nullable(BFTask *_Nonnull t) {
                                 [self dismissViewControllerAnimated:YES
                                                          completion:^{
                                                              if (self.deletedCell) {
                                                                  self.deletedCell(self.cell);
                                                              }
                                                          }];
                                 return nil;
                             }];
                         }
                     }];
}

#pragma mark - tableDeledate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.createCell)
        return 2;
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.createCell)
        if(indexPath.row == 7)
            return 200;
        else
            return 40;
    else
        if(indexPath.row == 1)
            return 200;
        else
            return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.createCell)
        switch (indexPath.row) {
            case 0:
                return self.nameCell;
            case 1:
                return self.idCell;
            case 2:
                return self.boxIndexCell;
            case 3:
                return self.createTimeCell;
            case 4:
                return self.boxInfoCell;
            case 5:
                return self.basketInfoCell;
            case 6:
                return self.canisterInfoCell;
            case 7:
                return self.noteCell;
            default:
                return nil;
        }
    else
        switch (indexPath.row) {
            case 0:
                return self.nameCell;
            case 1:
                return self.noteCell;
            default:
                return nil;
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 4:
        {
            CLEditBoxViewController *editBoxVC = [[CLEditBoxViewController alloc] initWithBox:self.box.firstObject];
            editBoxVC.refresh= ^(BOOL isDelete, NSObject *object)
            {
                NSLog(@"1CLEditCellrefresh:%@ %@",isDelete?@"Yes":@"No",object);
                if([self.box.firstObject isKindOfClass:[object class]])
                {
                    [self.box replaceObjectAtIndex:0 withObject:(CLBox *)object];
                    if(!isDelete)
                        [self.boxInfoCell.input setText:[NSString stringWithFormat:@"%@",self.box.firstObject.name]];
                    self.refresh(isDelete, object);
                }
                else if([self.basket.firstObject isKindOfClass:[object class]])
                {
                    [self.basket replaceObjectAtIndex:0 withObject:(CLBasket *)object];
                    if(!isDelete)
                        [self.basketInfoCell.input setText:[NSString stringWithFormat:@"%@",self.basket.firstObject.name]];
                    self.refresh(isDelete, object);
                }
                else if ([self.canister.firstObject isKindOfClass:[object class]])
                {
                    [self.canister replaceObjectAtIndex:0 withObject:(CLCanister *)object];
                    if(!isDelete)
                        [self.canisterInfoCell.input setText:[NSString stringWithFormat:@"%@",self.canister.firstObject.name]];
                    self.refresh(isDelete, object);
                }
                else
                    NSLog(@"Unmatch Class: %@",object);
            };
            editBoxVC.deletedBox = ^(CLBox *box) {
                NSLog(@"CLEditCellVC self: %@\nself.p: %@\nself.n: %@\n self.p.n: %@\nself.controllers:%@ --------",self,self.presentingViewController,self.navigationController,self.presentingViewController.navigationController,self.navigationController.viewControllers);
                
                UIViewController *rootVC=self;
                while (rootVC.presentingViewController) {
                    rootVC = rootVC.presentingViewController;
                    NSLog(@"[%@]",rootVC);
                }
                [rootVC dismissViewControllerAnimated:YES completion:^{
                    [(UINavigationController *)rootVC popToRootViewControllerAnimated:YES];
                }];
                editBoxVC.refresh(true, box);
            };
            editBoxVC.editedBox = ^(CLBox *box) {
                editBoxVC.refresh(false, box);
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editBoxVC] animated:YES completion:nil];
                });
        }
        case 5:
        {
            CLEditBasketViewController *editBasketVC = [[CLEditBasketViewController alloc] initWithBasket:self.basket.firstObject];
            editBasketVC.refresh= ^(BOOL isDelete, NSObject *object)
            {
                NSLog(@"2CLEditCellrefresh:%@ %@",isDelete?@"Yes":@"No",object);
                if([self.basket.firstObject isKindOfClass:[object class]])
                {
                    [self.basket replaceObjectAtIndex:0 withObject:(CLBasket *)object];
                    if(!isDelete)
                        [self.basketInfoCell.input setText:[NSString stringWithFormat:@"%@",self.basket.firstObject.name]];
                    self.refresh(isDelete, object);
                }
                else if ([self.canister.firstObject isKindOfClass:[object class]])
                {
                    [self.canister replaceObjectAtIndex:0 withObject:(CLCanister *)object];
                    if(!isDelete)
                        [self.canisterInfoCell.input setText:[NSString stringWithFormat:@"%@",self.canister.firstObject.name]];
                    self.refresh(isDelete, object);
                }
                else
                    NSLog(@"Unmatch Class: %@",object);
            };
            editBasketVC.deletedBasket = ^(CLBasket *basket) {
                NSLog(@"CLEditCellVC self: %@\nself.p: %@\nself.n: %@\n self.p.n: %@\nself.controllers:%@ --------",self,self.presentingViewController,self.navigationController,self.presentingViewController.navigationController,self.navigationController.viewControllers);
                
                UIViewController *rootVC=self;
                while (rootVC.presentingViewController) {
                    rootVC = rootVC.presentingViewController;
                    NSLog(@"[%@]",rootVC);
                }
                [rootVC dismissViewControllerAnimated:YES completion:^{
                    [(UINavigationController *)rootVC popToRootViewControllerAnimated:YES];
                }];
                editBasketVC.refresh(true, basket);
            };
            editBasketVC.editedBasket = ^(CLBasket *basket) {
                editBasketVC.refresh(false, basket);
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editBasketVC] animated:YES completion:nil];
                });
        }
        case 6:
        {
            CLEditCanisterViewController *editCanisterVC = [[CLEditCanisterViewController alloc] initWithCanister:self.canister.firstObject];
            editCanisterVC.refresh= ^(BOOL isDelete, NSObject *object)
            {
                NSLog(@"3CLEditCellrefresh:%@ %@",isDelete?@"Yes":@"No",object);
                if ([self.canister.firstObject isKindOfClass:[object class]])
                {
                    [self.canister replaceObjectAtIndex:0 withObject:(CLCanister *)object];
                    if(!isDelete)
                        [self.canisterInfoCell.input setText:[NSString stringWithFormat:@"%@",self.canister.firstObject.name]];
                    self.refresh(isDelete, object);
                }
                else
                    NSLog(@"Unmatch Class: %@",object);
            };
            editCanisterVC.deletedCanister = ^(CLCanister *canister) {
                NSLog(@"CLEditCellVC self: %@\nself.p: %@\nself.n: %@\n self.p.n: %@\nself.controllers:%@ --------",self,self.presentingViewController,self.navigationController,self.presentingViewController.navigationController,self.navigationController.viewControllers);
                
                UIViewController *rootVC=self;
                while (rootVC.presentingViewController) {
                    rootVC = rootVC.presentingViewController;
                    NSLog(@"[%@]",rootVC);
                }
                [rootVC dismissViewControllerAnimated:YES completion:^{
                    [(UINavigationController *)rootVC popToRootViewControllerAnimated:YES];
                }];
                editCanisterVC.refresh(true, canister);
            };
            editCanisterVC.editedCanister = ^(CLCanister *canister) {
                editCanisterVC.refresh(false, canister);
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editCanisterVC] animated:YES completion:nil];
                });
        }
        default:
            break;
    }
    
}


- (void)tableView:(UITableView*)list didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(!self.createCell&&[self.navigationItem.rightBarButtonItem.title isEqualToString:@"保存"])
    {
        switch (indexPath.row) {
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
                return [XCMessageHelper showHUDMessage:@"该信息不可修改"];
            default:
                break;
        }
    }
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
