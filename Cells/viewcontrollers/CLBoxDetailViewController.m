//
//  CLBoxDetailViewController.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/11/19.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLBox.h"
#import "CLBoxDetailCell.h"
#import "CLBoxDetailViewController.h"
#import "CLCell.h"
#import "CLCellDB.h"
#import "CLEditCellViewController.h"
#import "CLRedirect.h"
#import "NSDictionary+XCDBQuery.h"

static NSString * const kTitleCell = @"kTitleCell";

@interface CLBoxDetailTitleCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLb;

@end

@implementation CLBoxDetailTitleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor flatGrayColor] colorWithAlphaComponent:.3];
        _titleLb = [UILabel new];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.font = [XCFont lightFontWithSize:15];
        [self.contentView addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

@end

@interface CLBoxDetailCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, strong) NSMutableArray *itemAttributes;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation CLBoxDetailCollectionViewLayout

- (void)prepareLayout {
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    NSInteger columns = [self.collectionView numberOfItemsInSection:0];
    NSUInteger column = 0; // Current column inside row
    CGFloat xOffset = 0.0;
    CGFloat yOffset = 0.0;
    CGFloat contentWidth = 0.0;  // To determine the contentSize
    CGFloat contentHeight = 0.0; // To determine the contentSize

    if (self.itemAttributes.count > 0) { // We don't enter in this if statement the first time, we enter the following times
        for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
            NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
            for (NSUInteger index = 0; index < numberOfItems; index++) {
                if (section != 0 && index != 0) { // This is a content cell that shouldn't be sticked
                    continue;
                }
                UICollectionViewLayoutAttributes *attributes =
                [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
                if (section == 0) { // We stick the first row
                    CGRect frame = attributes.frame;
                    frame.origin.y = self.collectionView.contentOffset.y;
                    attributes.frame = frame;
                }
                if (index == 0) { // We stick the first column
                    CGRect frame = attributes.frame;
                    frame.origin.x = self.collectionView.contentOffset.x;
                    attributes.frame = frame;
                }
            }
        }

        return;
    }

    // The following code is only executed the first time we prepare the layout
    self.itemAttributes = [@[] mutableCopy];

    // Tip: If we don't know the number of columns we can call the following method and use the NSUInteger object instead of the
    // NUMBEROFCOLUMNS macro
    // NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];

    // We loop through all items
    for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
        NSMutableArray *sectionAttributes = [@[] mutableCopy];
        for (NSUInteger index = 0; index < columns; index++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
            CGSize itemSize = [self calculateItemsSizeForIndexPath:indexPath];
            // We create the UICollectionViewLayoutAttributes object for each item and add it to our array.
            // We will use this later in layoutAttributesForItemAtIndexPath:
            UICollectionViewLayoutAttributes *attributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));

            if (section == 0 && index == 0) {
                attributes.zIndex = 1024; // Set this value for the first item (Sec0Row0) in order to make it visible over first
                                          // column and first row
            } else if (section == 0 || index == 0) {
                attributes.zIndex =
                1023; // Set this value for the first row or section in order to set visible over the rest of the items
            }
            if (section == 0) {
                CGRect frame = attributes.frame;
                frame.origin.y = self.collectionView.contentOffset.y;
                attributes.frame = frame; // Stick to the top
            }
            if (index == 0) {
                CGRect frame = attributes.frame;
                frame.origin.x = self.collectionView.contentOffset.x;
                attributes.frame = frame; // Stick to the left
            }

            [sectionAttributes addObject:attributes];

            xOffset = xOffset + itemSize.width;
            column++;

            // Create a new row if this was the last column
            if (column == columns) {
                if (xOffset > contentWidth) {
                    contentWidth = xOffset;
                }

                // Reset values
                column = 0;
                xOffset = 0;
                yOffset += itemSize.height;
            }
        }
        [self.itemAttributes addObject:sectionAttributes];
    }

    // Get the last item to calculate the total height of the content
    UICollectionViewLayoutAttributes *attributes = [[self.itemAttributes lastObject] lastObject];
    contentHeight = attributes.frame.origin.y + attributes.frame.size.height;
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemAttributes[indexPath.section][indexPath.row];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [@[] mutableCopy];
    for (NSArray *section in self.itemAttributes) {
        [attributes
        addObjectsFromArray:[section filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject,
                                                                                                       NSDictionary *bindings) {
                                         return CGRectIntersectsRect(rect, [evaluatedObject frame]);
                                     }]]];
    }

    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES; // Set this to YES to call prepareLayout on every scroll
}

- (CGSize)calculateItemsSizeForIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 40);
}

@end

@interface CLBoxDetailViewController ()  <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) CLBox *box;
@property (nonatomic, strong) UICollectionView *list;
@property (nonatomic, strong) UIView *fillView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *fillLb;
@property (nonatomic, strong) UILabel *emptyLb;
@property (nonatomic, strong) NSMutableDictionary *cells;

@end

@implementation CLBoxDetailViewController

- (instancetype)initWithBox:(CLBox *)box {
    self = [super init];
    if (self) {
        _box = box;
        _cells = @{}.mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.box.name;
    [self.view addSubview:self.list];
    [self.view addSubview:self.fillView];
    [self.view addSubview:self.emptyView];
    [self.view addSubview:self.fillLb];
    [self.view addSubview:self.emptyLb];
    
    [self.emptyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        if(@available(iOS 11.0,*))
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        else
            make.top.equalTo(self.view).offset(74);
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        if(@available(iOS 11.0,*))
        {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(55);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(0);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(0);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(0);
        }
        else
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(120, 0, 0, 0));
    }];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.emptyLb);
        make.right.equalTo(self.emptyLb.mas_left).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.fillLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.emptyLb);
        make.right.equalTo(self.emptyView.mas_left).offset(-5);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [self.fillView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.emptyLb);
        make.right.equalTo(self.fillLb.mas_left).offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self loadCells];
    [self.list setContentSize:CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT)];
}

- (UILabel *)fillLb {
    if (!_fillLb) {
        _fillLb = [UILabel new];
        _fillLb.font = [XCFont lightFontWithSize:14];
        _fillLb.textAlignment = NSTextAlignmentCenter;
        _fillLb.text = @"有细胞";
    }
    return _fillLb;
}

- (UILabel *)emptyLb {
    if (!_emptyLb) {
        _emptyLb = [UILabel new];
        _emptyLb.font = [XCFont lightFontWithSize:14];
        _emptyLb.textAlignment = NSTextAlignmentCenter;
        _emptyLb.text = @"无细胞";
    }
    return _emptyLb;
}

- (UIView *)fillView {
    if (!_fillView) {
        _fillView = [UIView new];
        _fillView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.3];
    }
    return _fillView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [UIView new];
        _emptyView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    }
    return _emptyView;
}

- (UICollectionView *)list {
    if (!_list) {
        CLBoxDetailCollectionViewLayout *layout = [[CLBoxDetailCollectionViewLayout alloc] init];
        _list = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _list.backgroundColor = [UIColor whiteColor];
        _list.delegate = self;
        _list.dataSource = self;
        [_list registerClass:[CLBoxDetailCell class] forCellWithReuseIdentifier:kBoxDetailCell];
        [_list registerClass:[CLBoxDetailTitleCell class] forCellWithReuseIdentifier:kTitleCell];
    }
    return _list;
}

- (void)loadCells {
    [[CLCellDB sharedCLCellDB] getCellsWithCond:@{
        kDBAndCond: @[@"box_id=:box_id"],
        kDBAndValue: @{ @"box_id": @(self.box.bid) }
    }
    finishBlock:^(NSArray<CLCell *> *cells) {
        for (CLCell *cell in cells) {
            [self.cells setObject:cell forKey:@(cell.boxIndex)];
        }
        [self.list reloadData];
    }];
}
- (void)loadData
{
    self.navigationItem.title = self.box.name;
}

- (int)_boxIndexForIndexPath:(NSIndexPath *)indexPath {
    return (int)(indexPath.section * self.box.column + indexPath.row - 1);
}

#pragma mark - tableviewDelegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.box.row + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.box.column + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0 && indexPath.row != 0) {
        CLBoxDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBoxDetailCell forIndexPath:indexPath];
        [cell updateWithCell:[self.cells objectForKey:@([self _boxIndexForIndexPath:indexPath])]];
        return cell;
    } else {
        CLBoxDetailTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTitleCell forIndexPath:indexPath];
        if (indexPath.row == 0 && indexPath.section == 0) {
            cell.titleLb.text = @"行/列";
        } else if (indexPath.row == 0) {
            cell.titleLb.text = [NSString stringWithFormat:@"%@", @(indexPath.section)];
        } else {
            cell.titleLb.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!indexPath.row||!indexPath.section)
        return;
    if ([self.cells objectForKey:@([self _boxIndexForIndexPath:indexPath])]) {
        CLCell *cell = [self.cells objectForKey:@([self _boxIndexForIndexPath:indexPath])];
        CLEditCellViewController *editVC = [[CLEditCellViewController alloc] initWithCell:cell];
        editVC.refresh = ^(BOOL isDelete, NSObject *object)
        {
            NSLog(@"CLBoxDetailVCrefresh:%@ %@",isDelete?@"Yes":@"No",object);
            if([self.box isKindOfClass:[object class]])
            {
                self.box=(CLBox *)object;
                [self loadData];
            }
        };
        editVC.editedCell = ^(CLCell *cell) {
            [self.cells setObject:cell forKey:@(cell.boxIndex)];
            [self.list reloadData];
        };
        editVC.deletedCell = ^(CLCell *cell) {
            NSLog(@"CLBoxDetailVC self: %@\n self.presentingVC: %@\nself.controllers:%@ --------",self,self.presentingViewController,self.navigationController.viewControllers);
            [self.cells removeObjectForKey:@(cell.boxIndex)];
            [self.list reloadData];
        };
        [[CLRedirect sharedCLRedirect] presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC]];
//        [self presentViewController:editVC animated:YES completion:nil];
    } else {
        CLCell *cell = [CLCell new];
        cell.boxId = self.box.bid;
        cell.boxIndex = [self _boxIndexForIndexPath:indexPath];
        CLEditCellViewController *editVC = [[CLEditCellViewController alloc] initWithCell:cell];
        editVC.createdCell = ^(CLCell *cell) {
            [self.cells setObject:cell forKey:@(cell.boxIndex)];
            [self.list reloadData];
        };
        [[CLRedirect sharedCLRedirect] presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC]];
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
