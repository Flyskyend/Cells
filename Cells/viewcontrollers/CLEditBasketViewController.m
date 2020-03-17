//
//  CLEditBasketViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/2/20.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBasket.h"
#import "CLBasketDB.h"
#import "CLCanister.h"
#import "CLCanisterDB.h"
#import "CLEditBasketViewController.h"
#import "CLEditCanisterViewController.h"
#import "CLCanisterListViewController.h"
#import "XCInputCell.h"
#import <XCMessageHelper/XCMessageHelper.h>
#import "NSDictionary+XCDBQuery.h"
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

@interface CLEditBasketViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *list;
@property (nonatomic, assign) long cid;
@property (nonatomic, assign) BOOL createBasket;
@property (nonatomic, strong) NSMutableArray<CLCanister *> *canister;
@property (nonatomic, assign) CLBasket *basket;
@property (nonatomic, strong) XCInputCell *nameCell;
@property (nonatomic, strong) XCInputCell *bIdCell;
@property (nonatomic, strong) XCInputCell *createTimeCell;
@property (nonatomic, strong) XCInputCell *canisterInfoCell;
@property (nonatomic, strong) XCInputCell *noteCell;
@property (nonatomic, strong) UIButton *bottomBtn;
@end

@implementation CLEditBasketViewController

- (instancetype)initWithCanisterId:(long)cid {
    self = [super init];
    if (self) {
        _cid = cid;
        _createBasket = 1;
    }
    return self;
}

- (instancetype)initWithBasket:(CLBasket *)basket {
    self = [super init];
    if (self) {
        _basket = basket;
        _createBasket = basket.bid == 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.createBasket ? @"创建细胞篮" : @"细胞篮信息";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createBasket ? @"取消" : @"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createBasket?@"创建":@"修改" style:UIBarButtonItemStylePlain target:self action:self.createBasket? @selector(confirm:):@selector(modify:)];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    if(!self.createBasket){
        [self loadData];
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
        self.bottomBtn.hidden=YES;
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
//    CLCanisterListViewController *canisterDVC = [[CLCanisterListViewController alloc] init];
//    [self.navigationController pushViewController:canisterDVC animated:YES];
}

- (XCInputCell *)nameCell {
    if (!_nameCell) {
        _nameCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createBasket ? kInputCell : kInputCell_N];
        _nameCell.titleLb.attributedText = [XCGlobal makeAttString:@"名称" withFontSize:15];
    }
    return _nameCell;
}

- (XCInputCell *)noteCell {
    if (!_noteCell) {
        _noteCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createBasket ? kTextView_create : kTextView];
        _noteCell.titleLb.attributedText = [XCGlobal makeAttString:@"备注" withFontSize:15];
    }
    return _noteCell;
}

- (XCInputCell *)createTimeCell {
    if (!_createTimeCell) {
        _createTimeCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _createTimeCell.titleLb.attributedText = [XCGlobal makeAttString:@"创建日期" withFontSize:15];
    }
    return _createTimeCell;
}

- (XCInputCell *)canisterInfoCell {
    if (!_canisterInfoCell) {
        _canisterInfoCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _canisterInfoCell.titleLb.attributedText = [XCGlobal makeAttString:@"所在液氮罐" withFontSize:15];
        _canisterInfoCell.accessoryType=UITableViewCellAccessoryDetailButton;
    }
    return _canisterInfoCell;
}

- (XCInputCell *)bIdCell {
    if (!_bIdCell) {
        _bIdCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _bIdCell.titleLb.attributedText = [XCGlobal makeAttString:@"ID" withFontSize:15];
    }
    return _bIdCell;
}

-(void)loadData
{
    NSLog(@"1CLEditBasketVC-basket:%@",self.basket);
    [self.nameCell.input setText:self.basket.name];
    [self.createTimeCell.input setText:[XCGlobal formatTime:self.basket.createTime withFormat:@"YYYY-MM-dd HH:mm:ss"]];
    [self.bIdCell.input setText:[NSString stringWithFormat:@"%ld",self.basket.bid]];
    [self.noteCell.textview setText:self.basket.note];
    [[CLCanisterDB sharedCLCanisterDB] getCanistersWithCond:@{
        kDBAndCond: @[@"cid=:cid"],
        kDBAndValue: @{ @"cid": @(self.basket.canisterId) }
    }
    finishBlock:^(NSArray<CLCanister *> *canister) {
        self.canister = [canister mutableCopy];
        //NSLog(@"\n---------canister:%lu %@",self.canister.count,self.canister.firstObject);
        [self.canisterInfoCell.input setText:[NSString stringWithFormat:@"%@",self.canister.firstObject.name]];
    }];
}

- (void)backToInfo
{
    self.navigationItem.title=@"细胞篮信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modify:)];
    self.navigationItem.leftBarButtonItem.title = @"返回";
    [self.nameCell.input setEnabled:NO];
    [self.noteCell.textview setEditable:NO];
    self.bottomBtn.hidden = YES;
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
    self.navigationItem.title=@"修改细胞篮信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    self.navigationItem.leftBarButtonItem.title = @"取消";
    
    [self.nameCell.input setEnabled:YES];
    [self.noteCell.textview setEditable:YES];
    
    self.bottomBtn.hidden = NO;
}

- (IBAction)delete:(id)sender {
    [UIAlertController
    showAlertInViewController:self
                    withTitle:@"将删除细胞篮及篮内全部内容，是否确认删除"
                      message:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:@"删除"
            otherButtonTitles:nil
                     tapBlock:^(UIAlertController *_Nonnull controller, UIAlertAction *_Nonnull action, NSInteger buttonIndex) {
                         if (buttonIndex == controller.destructiveButtonIndex) {
                             [[[CLBasketDB sharedCLBasketDB] deleteBasket:self.basket] continueWithBlock:^id _Nullable(BFTask *_Nonnull t) {
                                     if (self.deletedBasket) {
                                         self.deletedBasket(self.basket);
                                     }
                                 return nil;
                             }];
                         }
                     }];
}

- (IBAction)confirm:(id)sender {
    [self.nameCell unFocus];
    if (!self.nameCell.input.text.length) {
        return [XCMessageHelper showHUDMessage:@"名称不能为空"];
    }
    if(self.createBasket)
    {
        NSMutableArray *conds = @[].mutableCopy;
        NSMutableDictionary *values = @{}.mutableCopy;
        [conds addObject:@"name=:name"];
        [values setObject:[NSString stringWithFormat:@"%@", self.nameCell.input.text] forKey:@"name"];
        [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLBasketDB *> *baskets) {
            if(baskets.count>0)
            {
                return [XCMessageHelper showHUDMessage:@"名称重复"];
            }
            CLBasket *basket = [[CLBasket alloc] init];
            basket.name = self.nameCell.input.text;
            basket.createTime = [XCGlobal now];
            basket.canisterId = self.cid;
            basket.note = self.noteCell.textview.text;
            [[CLBasketDB sharedCLBasketDB] cacheBasket:basket
                                             withFinishBlock:^(long long lastId){
                                                 basket.bid = lastId;
                                                 if (self.createdBasket) {
                                                     self.createdBasket(basket);
                                                 }
                                                 [self cancel:nil];
                                             }];}];
    }
    else
    {
        NSLog(@"2CLEditBasketVC-basket:%@",self.basket);
        _basket.name = self.nameCell.input.text;
        _basket.note = self.noteCell.textview.text;
        [[CLBasketDB sharedCLBasketDB] editBasket:self.basket withFinishBlock:^(long long lastId) {
            if(self.editedBasket)
            {
                self.editedBasket(self.basket);
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
    if(_createBasket)
        return 2;
    else
        return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.createBasket)
    {
        switch (indexPath.row) {
            case 0:
                return self.nameCell;
            case 1:
                return self.bIdCell;
            case 2:
                return self.createTimeCell;
            case 3:
                return self.canisterInfoCell;
            case 4:
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
                return self.noteCell;
            default:
                return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 3:
        {
            CLEditCanisterViewController *editCanisterVC = [[CLEditCanisterViewController alloc] initWithCanister:self.canister.firstObject];
            editCanisterVC.refresh= ^(BOOL isDelete, NSObject *object)
            {
                //NSLog(@"CLEditCellrefresh: %@ %@",isDelete?@"Yes":@"No",object);
                NSLog(@"CLEditBasketVC-canister:%@",self.canister);
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
    }
    
}


- (void)tableView:(UITableView*)list didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(!self.createBasket)
    {
        switch (indexPath.row) {
            case 1:
            case 2:
            case 3:
                return [XCMessageHelper showHUDMessage:@"该信息不可修改"];
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.createBasket)
        if(indexPath.row == 4)
            return 200;
        else
            return 40;
    else
        if(indexPath.row == 1)
            return 200;
        else
            return 40;
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
