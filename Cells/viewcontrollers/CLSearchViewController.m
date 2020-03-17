//
//  CLSearchViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/3/18.
//  Updated by 罗劭衡 on 2019/11/24.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLSearchViewController.h"
#import "CLSearchContentViewController.h"

@interface CLSearchViewController ()

@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) CLSearchContentViewController *currentContent;

@end

@implementation CLSearchViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _contents = @[].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"细胞罐", @"细胞篮", @"细胞盒", @"细胞"]];
    [self.segment addTarget:self action:@selector(segmentIndexChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment;
    [self _configContentViewControllers];
//    for (NSInteger i = 0; i < 3; i ++) {
//        [self.segment setEnabled:NO forSegmentAtIndex:i];
//    }
    self.segment.selectedSegmentIndex = 3;
    [self segmentIndexChanged:nil];
    self.navigationItem.backBarButtonItem.action=@selector(cancel:);
    
    //[[UIBackButt alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
}

- (void)_configContentViewControllers {
//    for (NSString *i in @[@"细胞罐", @"细胞篮", @"细胞盒", @"细胞"]) {
//        CLSearchContentViewController *contentVC = [[CLSearchContentViewController alloc] init];
//        [self.contents addObject:contentVC];
//    CLSearchCellsViewController *cellsVC = [[CLSearchCellsViewController alloc] init];
//        [self.contents addObject:cellsVC];}
    for (NSInteger i =0 ; i<4 ;i++) {
        CLSearchCellsViewController *cellsVC = [[CLSearchCellsViewController alloc] initWithId:i];
        [self.contents addObject:cellsVC];
    }
}

- (IBAction)segmentIndexChanged:(id)sender {
    NSInteger index = self.segment.selectedSegmentIndex;
    if (self.currentContent) {
        [self.currentContent.view removeFromSuperview];
        [self.currentContent removeFromParentViewController];
    }
    self.currentContent = [self.contents objectAtIndex:index];
    [self addChildViewController:self.currentContent];
    [self.currentContent didMoveToParentViewController:self];
    [self.view addSubview:self.currentContent.view];
    [self.currentContent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NAV_BAR_HEIGHT, 0, 0, 0));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25; // 动画时间
    transition.type = kCATransitionPush; // 动画样式
    transition.subtype = kCATransitionFromRight; // 动画方向
        
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
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
