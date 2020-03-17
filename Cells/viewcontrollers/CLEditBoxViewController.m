//
//  CLEditBoxViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/2/20.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBox.h"
#import "CLBoxDB.h"
#import "CLBasket.h"
#import "CLBasketDB.h"
#import "CLCanister.h"
#import "CLCanisterDB.h"
#import "CLEditBoxViewController.h"
#import "CLEditBasketViewController.h"
#import "CLEditCanisterViewController.h"
#import "CLBoxDetailViewController.h"
#import "XCInputCell.h"
#import <XCMessageHelper/XCMessageHelper.h>
#import "NSDictionary+XCDBQuery.h"
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

@interface CLEditBoxViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) long bid;
@property (nonatomic, assign) CLBox *box;
@property (nonatomic, assign) BOOL createBox;
@property (nonatomic, strong) NSMutableArray<CLBasket *> *basket;
@property (nonatomic, strong) NSMutableArray<CLCanister *> *canister;
@property (nonatomic, strong) UITableView *list;
@property (nonatomic, strong) XCInputCell *nameCell;
@property (nonatomic, strong) XCInputCell *rowCell;
@property (nonatomic, strong) XCInputCell *columnCell;
@property (nonatomic, strong) XCInputCell *createTimeCell;
@property (nonatomic, strong) XCInputCell *bIdCell;
@property (nonatomic, strong) XCInputCell *basketInfoCell;
@property (nonatomic, strong) XCInputCell *canisterInfoCell;
@property (nonatomic, strong) XCInputCell *noteCell;
@property (nonatomic, strong) UIButton *bottomBtn;

@end

@implementation CLEditBoxViewController

- (instancetype)initWithBasketId:(long)bid {
    self = [super init];
    if (self) {
        _bid = bid;
        _createBox = 1;
    }
    return self;
}

- (instancetype)initWithBox:(CLBox *)box {
    self = [super init];
    if (self) {
        _box = box;
        _createBox = box.bid == 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.createBox ? @"创建细胞盒" : @"细胞盒信息";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createBox ? @"取消":@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createBox? @"创建":@"修改" style:UIBarButtonItemStylePlain target:self action:self.createBox? @selector(confirm:):@selector(modify:)];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    if(!self.createBox) {
        [self loadData];
        
        UIButton *displayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [displayBtn setAttributedTitle:[XCGlobal makeAttString:@"显示视图" withFontSize:18 withColor:[UIColor whiteColor]]
                             forState:UIControlStateNormal];
        [displayBtn setBackgroundImage:[[UIColor flatGreenColor] image] forState:UIControlStateNormal];
        [self.view addSubview:displayBtn];
        [displayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(40);
        }];
        [displayBtn addTarget:self action:@selector(display:) forControlEvents:UIControlEventTouchUpInside];
        self.bottomBtn = displayBtn;
    }
    
    [self.nameCell focus];
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

- (void)display:(id)sender
{
    CLBoxDetailViewController *boxDVC = [[CLBoxDetailViewController alloc] initWithBox:_box];
    [self.navigationController pushViewController:boxDVC animated:YES];
}

- (XCInputCell *)nameCell {
    if (!_nameCell) {
        _nameCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createBox ? kInputCell : kInputCell_N];
        _nameCell.titleLb.attributedText = [XCGlobal makeAttString:@"名称" withFontSize:15];
    }
    return _nameCell;
}

- (XCInputCell *)noteCell {
    if (!_noteCell) {
        _noteCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createBox ? kTextView_create : kTextView];
        _noteCell.titleLb.attributedText = [XCGlobal makeAttString:@"备注" withFontSize:15];
    }
    return _noteCell;
}

- (XCInputCell *)rowCell {
    if (!_rowCell) {
        _rowCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createBox ? kInputCell : kInputCell_N];
        _rowCell.titleLb.attributedText = [XCGlobal makeAttString:@"行数" withFontSize:15];
        _rowCell.input.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _rowCell;
}

- (XCInputCell *)columnCell {
    if (!_columnCell) {
        _columnCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createBox ? kInputCell : kInputCell_N];
        _columnCell.titleLb.attributedText = [XCGlobal makeAttString:@"列数" withFontSize:15];
        _columnCell.input.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _columnCell;
}

- (XCInputCell *)createTimeCell {
    if (!_createTimeCell) {
        _createTimeCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _createTimeCell.titleLb.attributedText = [XCGlobal makeAttString:@"创建日期" withFontSize:15];
    }
    return _createTimeCell;
}

- (XCInputCell *)bIdCell {
    if (!_bIdCell) {
        _bIdCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _bIdCell.titleLb.attributedText = [XCGlobal makeAttString:@"ID" withFontSize:15];
    }
    return _bIdCell;
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

- (void)loadData
{
    [self.nameCell.input setText:self.box.name];
    [self.rowCell.input setText:[NSString stringWithFormat:@"%d",self.box.row]];
    [self.columnCell.input setText:[NSString stringWithFormat:@"%d",self.box.column]];
    [self.createTimeCell.input setText:[XCGlobal formatTime:self.box.createTime withFormat:@"YYYY-MM-dd HH:mm:ss"]];
    [self.bIdCell.input setText:[NSString stringWithFormat:@"%ld",self.box.bid]];
    [self.noteCell.textview setText:self.box.note];
    
    [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{
        kDBAndCond: @[@"bid=:bid"],
        kDBAndValue: @{ @"bid": @(self.box.basketId) }
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
}

- (void)backToInfo
{
    self.navigationItem.title=@"细胞盒信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modify:)];
    self.navigationItem.leftBarButtonItem.title = @"返回";
    [self.nameCell.input setEnabled:NO];
    [self.noteCell.textview setEditable:NO];
    UIButton *displayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [displayBtn setAttributedTitle:[XCGlobal makeAttString:@"显示视图" withFontSize:18 withColor:[UIColor whiteColor]]
                         forState:UIControlStateNormal];
    [displayBtn setBackgroundImage:[[UIColor flatGreenColor] image] forState:UIControlStateNormal];
    [self.view addSubview:displayBtn];
    [displayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    [displayBtn addTarget:self action:@selector(display:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomBtn = displayBtn;
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
    self.navigationItem.title=@"修改细胞盒信息";
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
    self.bottomBtn = delete;
}

- (IBAction)delete:(id)sender {
    [UIAlertController
    showAlertInViewController:self
                    withTitle:@"将删除细胞盒及盒内全部细胞，是否确认删除"
                      message:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:@"删除"
            otherButtonTitles:nil
                     tapBlock:^(UIAlertController *_Nonnull controller, UIAlertAction *_Nonnull action, NSInteger buttonIndex) {
                         if (buttonIndex == controller.destructiveButtonIndex) {
                             [[[CLBoxDB sharedCLBoxDB] deleteBox:self.box] continueWithBlock:^id _Nullable(BFTask *_Nonnull t) {
                                     if (self.deletedBox) {
                                         self.deletedBox(self.box);
                                     }
                                 return nil;
                             }];
                         }
                     }];
}

- (IBAction)confirm:(id)sender {
    [self.nameCell unFocus];
    if (!self.nameCell.input.text.length)
        return [XCMessageHelper showHUDMessage:@"名称不能为空"];
    else if(!self.rowCell.input.text.length)
        return [XCMessageHelper showHUDMessage:@"行数不能为空"];
    else if(!self.columnCell.input.text.length)
        return [XCMessageHelper showHUDMessage:@"列数不能为空"];
    else if(self.rowCell.input.text.intValue==0||self.columnCell.input.text.intValue==0)
        return [XCMessageHelper showHUDMessage:@"行/列数输入值异常"];
    
    if (self.createBox)
    {
        NSMutableArray *conds = @[].mutableCopy;
        NSMutableDictionary *values = @{}.mutableCopy;
        [conds addObject:@"name=:name"];
        [values setObject:[NSString stringWithFormat:@"%@", self.nameCell.input.text] forKey:@"name"];
        [[CLBoxDB sharedCLBoxDB] getBoxsWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLBoxDB *> *boxs) {
            if(boxs.count>0)
            {
                return [XCMessageHelper showHUDMessage:@"名称重复"];
            }
            CLBox *box = [[CLBox alloc] init];
            box.name = self.nameCell.input.text;
            box.note = self.noteCell.textview.text;
            box.row = self.rowCell.input.text.intValue;
            box.column = self.columnCell.input.text.intValue;
            box.createTime = [XCGlobal now];
            box.basketId = self.bid;
            [[CLBoxDB sharedCLBoxDB] cacheBox:box
                              withFinishBlock:^(long long lastId) {
                                  box.bid = lastId;
                                  if (self.createdBox) {
                                      self.createdBox(box);
                                  }
                                  [self cancel:nil];
                              }];
        }];
    }
    else
    {
        self.box.name = self.nameCell.input.text;
        self.box.note = self.noteCell.textview.text;
        self.box.row = self.rowCell.input.text.intValue;
        self.box.column = self.columnCell.input.text.intValue;
        [[CLBoxDB sharedCLBoxDB] editBox:self.box withFinishBlock:^(long long lastId) {
            if (self.editedBox) {
                self.editedBox(self.box);
            }
            [self backToInfo];
        }];
    }
}

#pragma mark - tableDeledate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_createBox)
        return 4;
    else
        return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.createBox)
    {
        switch (indexPath.row) {
            case 0:
                return self.nameCell;
            case 1:
                return self.rowCell;
            case 2:
                return self.columnCell;
            case 3:
                return self.bIdCell;
            case 4:
                return self.createTimeCell;
            case 5:
                return self.basketInfoCell;
            case 6:
                return self.canisterInfoCell;
            case 7:
                return self.noteCell;
            default:
                return nil;
        }
    }
    else
    {
        switch (indexPath.row) {
        case 0:
            return self.nameCell;
        case 1:
            return self.rowCell;
        case 2:
            return self.columnCell;
        case 3:
            return self.noteCell;
        default:
            return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 5:
        {
            CLEditBasketViewController *editBasketVC = [[CLEditBasketViewController alloc] initWithBasket:self.basket.firstObject];
            editBasketVC.refresh= ^(BOOL isDelete, NSObject *object)
            {
                NSLog(@"CLEditCellrefresh:%@ %@",isDelete?@"Yes":@"No",object);
                if([self.basket.firstObject isKindOfClass:[object class]])
                {
                    NSLog(@"CLEditBoxVC-basket:%@",self.canister);
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
                NSLog(@"CLEditCellrefresh:%@ %@",isDelete?@"Yes":@"No",object);
                if ([self.canister.firstObject isKindOfClass:[object class]])
                {
                    [self.canister replaceObjectAtIndex:0 withObject:(CLCanister *)object];
                    if(!isDelete)
                        [self loadData];
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
    if(!self.createBox&&[self.navigationItem.rightBarButtonItem.title isEqualToString:@"保存"])
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.createBox)
        if(indexPath.row == 7)
            return 200;
        else
            return 40;
    else
        if(indexPath.row == 3)
            return 200;
        else
            return 40;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"CLEBVCviewWillApper:self.box:%@",self.box);
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
