//
//  CLCanisterListViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCanisterCell.h"
#import "CLCanisterDB.h"
#import "CLCanister.h"
#import "CLCanisterListViewController.h"
#import "CLCanisterDetailViewController.h"
#import "CLEditCanisterViewController.h"
#import "CLSearchViewController.h"
#import "XCPopoverMenu.h"

@interface CLCanisterListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *list;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) NSMutableArray<CLCanister *> *canisters;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) XCPopoverMenu *popover;
@property (nonatomic, assign) BOOL shouldRefresh;
@property (strong, nonatomic) UIDocumentInteractionController *fileDC;

@end

@implementation CLCanisterListViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _canisters = @[].mutableCopy;
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        _shouldRefresh = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"液氮罐";
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setImage:[UIImage imageNamed:@"ic_bar_search"] forState:UIControlStateNormal];
    searchBtn.frame = CGRectMake(0, 0, 40, 40);
    searchBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [searchBtn addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = [XCFont lightFontWithSize:16];
    [refreshBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [exportBtn setTitle:@"导出" forState:UIControlStateNormal];
    exportBtn.titleLabel.font = [XCFont lightFontWithSize:16];
    [exportBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [exportBtn addTarget:self action:@selector(exportDB:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 10;
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)) {
        searchBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    self.navigationItem.leftBarButtonItems = @[spacer, [[UIBarButtonItem alloc] initWithCustomView:searchBtn]];
    self.navigationItem.rightBarButtonItems = @[
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCanister:)],
    spacer,
    [[UIBarButtonItem alloc] initWithCustomView:exportBtn],
    spacer,
    [[UIBarButtonItem alloc] initWithCustomView:refreshBtn]
    ];
    [self.view addSubview:self.list];
    [self.view addSubview:self.previousButton];
    [self.view addSubview:self.nextButton];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 20, 50, 20));
    }];
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.view);
        make.right.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.list.mas_bottom);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.view);
        make.left.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.list.mas_bottom);
    }];
    [self loadCanisters];
    @weakify(self);
    [[RACObserve(self, currentIndexPath) takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSIndexPath *path) {
        @strongify(self);
        self.previousButton.enabled = path.row != 0;
        self.nextButton.enabled = path.row != self.canisters.count - 1;
    }];
    [[RACObserve(self, canisters) takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSMutableArray *canisters) {
        @strongify(self);
        self.nextButton.hidden = self.previousButton.hidden = canisters.count <= 1;
        if(self.currentIndexPath.row == canisters.count+1)
            self.currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.row - 1 inSection:0];
        self.previousButton.enabled = self.currentIndexPath.row != 0;
        self.nextButton.enabled = self.currentIndexPath.row != self.canisters.count - 1;
    }];
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;//可更改为其他方式
    transition.subtype = kCATransitionFromTop;//可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addCanister:(id)sender {
    CLEditCanisterViewController *editVC = [[CLEditCanisterViewController alloc] init];
    editVC.createdCanister = ^(CLCanister *canister) {
        [self willChangeValueForKey:@"canisters"];
        [self.canisters addObject:canister];
        [self didChangeValueForKey:@"canisters"];
        [self.list reloadData];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
}

- (IBAction)refresh:(id)sender {
    [self loadCanisters];
    
}

- (IBAction)exportDB:(id)sender {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    self.popover = [[XCPopoverMenu alloc] init];
    @weakify(self);
    NSArray *files=@[@"basket.db", @"box.db", @"canister.db", @"cell.db", @"version.db"];
    [self.popover showFromSender:sender
              withMenuArray:files
                 imageArray:@[]
              selectedIndex:0
                  doneBlock:^(NSInteger selectedIndex) {
                      @strongify(self);
                      NSString *filePath = [[paths[0] stringByAppendingPathComponent:@"userDB"] stringByAppendingPathComponent:[files objectAtIndex:selectedIndex]];
                      NSLog(@"%@",filePath);
                      _fileDC = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                      _fileDC.UTI = @"";
                      [_fileDC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
                  }
               dismissBlock:^{
               }];
}

- (IBAction)search:(id)sender {
    self.shouldRefresh=YES;
    CLSearchViewController *search = [[CLSearchViewController alloc] init];

//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.25; // 动画时间
//    transition.type = kCATransitionPush; // 动画样式
//    transition.subtype = kCATransitionFromLeft; // 动画方向
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.navigationController pushViewController:search animated:NO]; // 注意这里 animated 必须设置为 NO
    
    [self.navigationController pushViewController:search animated:YES];
//    self.popover = [[XCPopoverMenu alloc] init];
//    @weakify(self);
//    [self.popover showFromSender:sender
//              withMenuArray:@[@"细胞罐", @"细胞篮", @"细胞盒", @"细胞"]
//                 imageArray:@[]
//              selectedIndex:0
//                  doneBlock:^(NSInteger selectedIndex) {
//                      @strongify(self);
//                      switch (selectedIndex) {
//                          case 0:
//                              [self _searchCanister];
//                              break;
//                          default:
//                              break;
//                      }
//                  }
//               dismissBlock:^{
//               }];
}

- (UICollectionView *)list {
    if (!_list) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT * .7);
        layout.minimumLineSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _list = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _list.backgroundColor = [UIColor whiteColor];
        _list.delegate = self;
        _list.dataSource = self;
        _list.scrollEnabled = NO;
        [_list registerClass:[CLCanisterCell class] forCellWithReuseIdentifier:kCanisterCell];
    }
    return _list;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setTitle:@"下一罐" forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton setBackgroundImage:[[UIColor flatBlueColor] image] forState:UIControlStateNormal];
    }
    return _nextButton;
}

- (UIButton *)previousButton {
    if (!_previousButton) {
        _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previousButton setTitle:@"上一罐" forState:UIControlStateNormal];
        [_previousButton addTarget:self action:@selector(onPrevious:) forControlEvents:UIControlEventTouchUpInside];
        [_previousButton setBackgroundImage:[[UIColor flatBlueColor] image] forState:UIControlStateNormal];
    }
    return _previousButton;
}

- (void)loadCanisters {
    [[CLCanisterDB sharedCLCanisterDB] getCanistersWithFinishBlock:^(NSArray<CLCanister *> *canisters) {
        [self willChangeValueForKey:@"canisters"];
        self.canisters = [canisters mutableCopy];
        [self didChangeValueForKey:@"canisters"];
        [self.list reloadData];
    }];
}

- (IBAction)onPrevious:(id)sender {
    [self.list scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPath.row - 1 inSection:0]
                      atScrollPosition:UICollectionViewScrollPositionNone
                              animated:YES];
    self.currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.row - 1 inSection:0];
//    NSLog(@"currentIndexPath: %@\nCanister.count: %d",self.currentIndexPath.row,self.canisters.count);
}

- (IBAction)onNext:(id)sender {
    [self.list scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPath.row + 1 inSection:0]
                      atScrollPosition:UICollectionViewScrollPositionNone
                              animated:YES];
    self.currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndexPath.row + 1 inSection:0];
//    NSLog(@"currentIndexPath: %@\nCanister.count: %d",self.currentIndexPath.row,self.canisters.count);
}

- (void)_searchCanister {
    UIAlertController *commitVC =
    [UIAlertController alertControllerWithTitle:@"搜索液氮罐名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    @weakify(self);
    UIAlertAction *commit = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       NSString *text = commitVC.textFields.firstObject.text;
                                                       @strongify(self);
                                                       if ([text length]) {
                                                       } else {
                                                       }
                                                   }];
    [commitVC addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField){
    }];
    [commitVC addAction:cancel];
    [commitVC addAction:commit];
    [self presentViewController:commitVC animated:YES completion:nil];
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.canisters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CLCanisterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCanisterCell forIndexPath:indexPath];
    [cell updateWithCanister:self.canisters[indexPath.row]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadCanisters];
//    NSLog(@"currentIndexPath: %@\nCanister.count: %d",self.currentIndexPath,self.canisters.count);
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
