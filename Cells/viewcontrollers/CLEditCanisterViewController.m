//
//  CLEditCanisterViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Updated by 罗劭衡 on 2019/2/20.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLEditCanisterViewController.h"
#import "XCInputCell.h"
#import "CLCanisterDB.h"
#import "CLCanister.h"
#import <XCMessageHelper/XCMessageHelper.h>
#import "NSDictionary+XCDBQuery.h"
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

@interface CLEditCanisterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *list;
@property (nonatomic, assign) BOOL createCanister;
@property (nonatomic, assign) CLCanister *canister;
@property (nonatomic, strong) XCInputCell *nameCell;
@property (nonatomic, strong) XCInputCell *createTimeCell;
@property (nonatomic, strong) XCInputCell *cIdCell;
@property (nonatomic, strong) XCInputCell *noteCell;
@property (nonatomic, strong) UIButton *bottomBtn;


@end

@implementation CLEditCanisterViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _createCanister = 1;
    }
    return self;
}

- (instancetype)initWithCanister:(CLCanister *)canister {
    self = [super init];
    if (self) {
        _canister = canister;
        _createCanister = canister.cid == 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.createCanister ? @"创建液氮罐" : @"液氮罐信息";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: self.createCanister ? @"取消" : @"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.createCanister?@"创建":@"修改" style:UIBarButtonItemStylePlain target:self action:self.createCanister? @selector(confirm:):@selector(modify:)];
    [self.view addSubview:self.list];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    if(!self.createCanister)
    {
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

- (XCInputCell *)nameCell {
    if (!_nameCell) {
        _nameCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createCanister ? kInputCell : kInputCell_N];
        _nameCell.titleLb.attributedText = [XCGlobal makeAttString:@"名称" withFontSize:15];
    }
    return _nameCell;
}

- (XCInputCell *)noteCell {
    if (!_noteCell) {
        _noteCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.createCanister ? kTextView_create : kTextView];
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

- (XCInputCell *)cIdCell {
    if (!_cIdCell) {
        _cIdCell = [[XCInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCell_N];
        _cIdCell.titleLb.attributedText = [XCGlobal makeAttString:@"ID" withFontSize:15];
    }
    return _cIdCell;
}

- (void)loadData
{
    [self.nameCell.input setText:self.canister.name];
    [self.createTimeCell.input setText:[XCGlobal formatTime:self.canister.createTime withFormat:@"YYYY-MM-dd HH:mm:ss"]];
    [self.cIdCell.input setText:[NSString stringWithFormat:@"%ld",self.canister.cid]];
    [self.noteCell.textview setText:self.canister.note];
}

- (void)backToInfo
{
    self.navigationItem.title=@"液氮罐信息";
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
    self.navigationItem.title=@"修改液氮罐信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    self.navigationItem.leftBarButtonItem.title = @"取消";
    
    [self.nameCell.input setEnabled:YES];
    [self.noteCell.textview setEditable:YES];
    
    self.bottomBtn.hidden = NO;
}

- (IBAction)delete:(id)sender {
    [UIAlertController
    showAlertInViewController:self
                    withTitle:@"将删除液氮罐及罐内全部内容，是否确认删除"
                      message:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:@"删除"
            otherButtonTitles:nil
                     tapBlock:^(UIAlertController *_Nonnull controller, UIAlertAction *_Nonnull action, NSInteger buttonIndex) {
                         if (buttonIndex == controller.destructiveButtonIndex) {
                             [[[CLCanisterDB sharedCLCanisterDB] deleteCanister:self.canister] continueWithBlock:^id _Nullable(BFTask *_Nonnull t) {
                                     if (self.deletedCanister) {
                                         self.deletedCanister(self.canister);
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
    if(self.createCanister)
    {
        NSMutableArray *conds = @[].mutableCopy;
        NSMutableDictionary *values = @{}.mutableCopy;
        [conds addObject:@"name=:name"];
        [values setObject:[NSString stringWithFormat:@"%@", self.nameCell.input.text] forKey:@"name"];
        [[CLCanisterDB sharedCLCanisterDB] getCanistersWithCond:@{kDBAndCond:conds, kDBAndValue:values} finishBlock:^(NSArray<CLCanisterDB *> *canisters) {
            if(canisters.count>0)
            {
                return [XCMessageHelper showHUDMessage:@"名称重复"];
            }
            CLCanister *canister = [[CLCanister alloc] init];
            canister.name = self.nameCell.input.text;
            canister.createTime = [XCGlobal now];
            canister.note = self.noteCell.textview.text;
            [[CLCanisterDB sharedCLCanisterDB] cacheCanister:canister
                                             withFinishBlock:^(long long lastId){
                                                 canister.cid = lastId;
                                                 if (self.createdCanister) {
                                                     self.createdCanister(canister);
                                                 }
                                                 [self cancel:nil];
                                             }];
        }];
    }
    else
    {
        _canister.name = self.nameCell.input.text;
        _canister.note = self.noteCell.textview.text;
        [[CLCanisterDB sharedCLCanisterDB] editCanister:self.canister withFinishBlock:^(long long lastId) {
            if(self.editedCanister)
            {
                self.editedCanister(self.canister);
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
    if(_createCanister)
        return 2;
    else
        return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.createCanister)
    {
        switch (indexPath.row) {
            case 0:
                return self.nameCell;
            case 1:
                return self.cIdCell;
            case 2:
                return self.createTimeCell;
            case 3:
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

- (void)tableView:(UITableView*)list didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(!self.createCanister)
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
    if(!self.createCanister)
        if(indexPath.row == 3)
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
