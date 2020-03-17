//
//  CLCanisterCell.m
//  Cells
//
//  Created by 王新晨 on 2018/1/13.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBasketCell.h"
#import "CLBasketDB.h"
#import "CLBasket.h"
#import "CLCanisterCell.h"
#import "CLCanister.h"
#import "CLRedirect.h"
#import "CLEditBasketViewController.h"
#import "CLEditCanisterViewController.h"
#import "NSDictionary+XCDBQuery.h"

@interface CLCanisterCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) CLCanister *canister;
@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UILabel *dateLb;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UICollectionView *list;
@property (nonatomic, strong) NSMutableArray *baskets;

@end

@implementation CLCanisterCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _baskets = @[].mutableCopy;
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
        [self.contentView addSubview:self.nameLb];
        [self.contentView addSubview:self.dateLb];
        [self.contentView addSubview:self.list];
        [self.contentView addSubview:self.addButton];
        [self.contentView addSubview:self.infoButton];
        [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(10);
            //make.right.equalTo(self.contentView).offset(-100);
            make.height.mas_equalTo(20);
        }];
        [self.dateLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.contentView).offset(-60);
            make.top.equalTo(self.nameLb.mas_bottom).offset(5);
            make.height.mas_equalTo(20);
        }];
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(10);
            make.size.mas_equalTo(CGSizeMake(60, 20));
        }];
        [self.infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLb.mas_right).offset(5);
            make.top.equalTo(self.nameLb.mas_top).offset(-1.5);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];
        [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(60, 10, 10, 10));
        }];
    }
    return self;
}

- (UILabel *)nameLb {
    if (!_nameLb) {
        _nameLb = [[UILabel alloc] init];
        _nameLb.numberOfLines = 0;
        _nameLb.font = [XCFont lightFontWithSize:16];
    }
    return _nameLb;
}

- (UILabel *)dateLb {
    if (!_dateLb) {
        _dateLb = [[UILabel alloc] init];
        _dateLb.numberOfLines = 0;
        _dateLb.font = [XCFont lightFontWithSize:15];
        _dateLb.textColor = [UIColor lightGrayColor];
    }
    return _dateLb;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:@"加一篮" forState:UIControlStateNormal];
        _addButton.titleLabel.font = [XCFont lightFontWithSize:16];
        [_addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addBasket:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UIButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        _infoButton.titleLabel.font = [XCFont lightFontWithSize:16];
//        [_infoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(canisterInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoButton;
}

- (UICollectionView *)list {
    if (!_list) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, SCREEN_HEIGHT * .55);
        layout.minimumLineSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _list = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _list.backgroundColor = [UIColor whiteColor];
        _list.delegate = self;
        _list.dataSource = self;
        [_list registerClass:[CLBasketCell class] forCellWithReuseIdentifier:kBasketCell];
    }
    return _list;
}

- (void)updateWithCanister:(CLCanister *)canister {
    _canister = canister;
    self.nameLb.text = canister.name;
    self.dateLb.text = [XCGlobal formatTime:canister.createTime withFormat:@"YYYY年MM月dd日"];
    [[CLBasketDB sharedCLBasketDB] getBasketsWithCond:@{
        kDBAndCond: @[@"canister_id=:canister_id"],
        kDBAndValue: @{ @"canister_id": @(canister.cid) }
    }
    finishBlock:^(NSArray<CLBasket *> *baskets) {
        self.baskets = [baskets mutableCopy];
        [self.list reloadData];
    }];
}

- (IBAction)addBasket:(id)sender {
    CLEditBasketViewController *editVC = [[CLEditBasketViewController alloc] initWithCanisterId:self.canister.cid];
    editVC.createdBasket = ^(CLBasket *basket) {
        [self.baskets addObject:basket];
        [self.list reloadData];
    };
    [[CLRedirect sharedCLRedirect] presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC]];
}

- (IBAction)canisterInfo:(id)sender {
    CLEditCanisterViewController *editCanisterVC = [[CLEditCanisterViewController alloc] initWithCanister:self.canister];
    editCanisterVC.deletedCanister = ^(CLCanister *canister) {
        
    };
    editCanisterVC.editedCanister = ^(CLCanister *canister) {
        
    };
    [[CLRedirect sharedCLRedirect] presentViewController:[[UINavigationController alloc] initWithRootViewController:editCanisterVC]];
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.baskets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CLBasketCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBasketCell forIndexPath:indexPath];
    [cell updateWithBasket:[self.baskets objectAtIndex:indexPath.row]];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
