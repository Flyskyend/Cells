//
//  XCPopoverMenu.h
//  Cells
//
//  Created by 王新晨 on 2018/3/17.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "XCPopoverMenu.h"

// changeable
#define XCPopoverMenuDefaultMargin                     0.f
#define XCPopoverMenuDefaultMenuTextMargin             6.f
#define XCPopoverMenuDefaultMenuIconMargin             12.f
#define XCPopoverMenuDefaultMenuCornerRadius           5.f
#define XCPopoverMenuDefaultAnimationDuration          0.2
// unchangeable, change them at your own risk
#define XCPopoverMenuDefaultBackgroundColor            [UIColor clearColor]
#define XCPopoverMenuDefaultTintColor                  [UIColor colorWithRed:0xFF/255.f green:0xFF/255.f blue:0xFF/255.f alpha:1]
#define XCPopoverMenuDefaultTextColor                  [UIColor lightGrayColor]
#define XCPopoverMenuDefaultMenuFont                   [XCFont lightFontWithSize:18]
#define XCPopoverMenuDefaultMenuWidth                  120.f
#define XCPopoverMenuDefaultMenuIconSize               24.f
#define XCPopoverMenuDefaultMenuRowHeight              50.f
#define XCPopoverMenuDefaultMenuBorderWidth            0.8
#define XCPopoverMenuDefaultMenuArrowWidth             8.f
#define XCPopoverMenuDefaultMenuArrowHeight            10.f
#define XCPopoverMenuDefaultMenuArrowWidth_R           12.f
#define XCPopoverMenuDefaultMenuArrowHeight_R          12.f
#define XCPopoverMenuDefaultMenuArrowRoundRadius       4.f

static NSString  *const XCPopoverMenuTableViewCellIndentifier = @"XCPopoverMenuTableViewCellIndentifier";

typedef NS_ENUM(NSUInteger, XCPopoverMenuArrowDirection) {
    /**
     *  Up
     */
    XCPopoverMenuArrowDirectionUp,
    /**
     *  Down
     */
    XCPopoverMenuArrowDirectionDown,
};

#pragma mark - XCPopoverMenuConfiguration

@implementation XCPopoverMenuConfiguration

+ (XCPopoverMenuConfiguration *)defaultConfiguration {
    XCPopoverMenuConfiguration *configuration = [[XCPopoverMenuConfiguration alloc] init];
    return configuration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.menuRowHeight = XCPopoverMenuDefaultMenuRowHeight;
        self.menuWidth = XCPopoverMenuDefaultMenuWidth;
        self.textColor = XCPopoverMenuDefaultTextColor;
        self.selectedTextColor = [UIColor lightGrayColor];
        self.textFont = XCPopoverMenuDefaultMenuFont;
        self.tintColor = XCPopoverMenuDefaultTintColor;
        self.borderColor = [UIColor lightGrayColor];
        self.borderWidth = XCPopoverMenuDefaultMenuBorderWidth;
        self.textAlignment = NSTextAlignmentCenter;
        self.ignoreImageOriginalColor = NO;
        self.allowRoundedArrow = YES;
        self.menuTextMargin = XCPopoverMenuDefaultMenuTextMargin;
        self.menuIconMargin = XCPopoverMenuDefaultMenuIconMargin;
        self.animationDuration = XCPopoverMenuDefaultAnimationDuration;
    }
    return self;
}

@end

#pragma mark - XCPopoverMenuCell

@interface XCPopoverMenuCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *menuNameLabel;

@end

@implementation XCPopoverMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     menuName:(NSString *)menuName
                    menuImage:(NSString *)menuImage
                 selectedCell:(BOOL)selectedCell {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupWithMenuName:menuName menuImage:menuImage selectedCell:selectedCell];
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)menuNameLabel {
    if (!_menuNameLabel) {
        _menuNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _menuNameLabel.backgroundColor = [UIColor clearColor];
    }
    return _menuNameLabel;
}

- (void)setupWithMenuName:(NSString *)menuName menuImage:(NSString *)menuImage selectedCell:(BOOL)selectedCell {
    XCPopoverMenuConfiguration *configuration = [XCPopoverMenuConfiguration defaultConfiguration];

    CGFloat margin = (configuration.menuRowHeight - XCPopoverMenuDefaultMenuIconSize) / 2.f;
    CGRect iconImageRect =
    CGRectMake(configuration.menuIconMargin, margin, XCPopoverMenuDefaultMenuIconSize, XCPopoverMenuDefaultMenuIconSize);
    CGFloat menuNameX = iconImageRect.origin.x + iconImageRect.size.width + configuration.menuTextMargin;
    CGRect menuNameRect =
    CGRectMake(menuNameX, 0, configuration.menuWidth - menuNameX - configuration.menuTextMargin, configuration.menuRowHeight);

    if (!menuImage) {
        menuNameRect = CGRectMake(configuration.menuTextMargin, 0, configuration.menuWidth - configuration.menuTextMargin * 2,
                                  configuration.menuRowHeight);
    } else {
        self.iconImageView.frame = iconImageRect;
        self.iconImageView.tintColor = configuration.textColor;
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", menuImage, selectedCell ? @"_selected" : @""]];
        if (configuration.ignoreImageOriginalColor) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _iconImageView.image = image;
        [self.contentView addSubview:self.iconImageView];
    }
    self.menuNameLabel.frame = menuNameRect;
    self.menuNameLabel.font = configuration.textFont;
    self.menuNameLabel.textColor = selectedCell ? configuration.selectedTextColor : configuration.textColor;
    self.menuNameLabel.textAlignment = configuration.textAlignment;
    self.menuNameLabel.text = menuName;
    [self.contentView addSubview:self.menuNameLabel];
}

@end

#pragma mark - XCPopoverMenuView

@interface XCPopoverMenuView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSArray<NSString *> *menuStringArray;
@property (nonatomic, strong) NSArray *menuImageArray;
@property (nonatomic, assign) XCPopoverMenuArrowDirection arrowDirection;
@property (nonatomic, strong) XCPopoverMenuDoneBlock doneBlock;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation XCPopoverMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuTableView.backgroundColor = XCPopoverMenuDefaultBackgroundColor;
        _menuTableView.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:.1];
        _menuTableView.layer.cornerRadius = XCPopoverMenuDefaultMenuCornerRadius;
        _menuTableView.scrollEnabled = NO;
        _menuTableView.clipsToBounds = YES;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [self addSubview:_menuTableView];
    }
    return _menuTableView;
}

- (CGFloat)menuArrowWidth {
    return [XCPopoverMenuConfiguration defaultConfiguration].allowRoundedArrow ? XCPopoverMenuDefaultMenuArrowWidth_R :
    XCPopoverMenuDefaultMenuArrowWidth;
}

- (CGFloat)menuArrowHeight {
    return [XCPopoverMenuConfiguration defaultConfiguration].allowRoundedArrow ? XCPopoverMenuDefaultMenuArrowHeight_R :
    XCPopoverMenuDefaultMenuArrowHeight;
}

- (void)showWithFrame:(CGRect)frame
           anglePoint:(CGPoint)anglePoint
        withNameArray:(NSArray<NSString *> *)nameArray
       imageNameArray:(NSArray *)imageNameArray
        selectedIndex:(NSInteger)selectedIndex
     shouldAutoScroll:(BOOL)shouldAutoScroll
       arrowDirection:(XCPopoverMenuArrowDirection)arrowDirection
            doneBlock:(XCPopoverMenuDoneBlock)doneBlock {
    self.frame = frame;
    _menuStringArray = nameArray;
    _menuImageArray = imageNameArray;
    _arrowDirection = arrowDirection;
    self.selectedIndex = selectedIndex;
    self.doneBlock = doneBlock;
    self.menuTableView.scrollEnabled = shouldAutoScroll;

    CGRect menuRect = CGRectMake(0, self.menuArrowHeight, self.frame.size.width, self.frame.size.height - self.menuArrowHeight);
    if (_arrowDirection == XCPopoverMenuArrowDirectionDown) {
        menuRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.menuArrowHeight);
    }
    [self.menuTableView setFrame:menuRect];
    [self.menuTableView reloadData];

    [self drawBackgroundLayerWithAnglePoint:anglePoint];
}

- (void)drawBackgroundLayerWithAnglePoint:(CGPoint)anglePoint {
    if (_backgroundLayer) {
        [_backgroundLayer removeFromSuperlayer];
    }

    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL allowRoundedArrow = [XCPopoverMenuConfiguration defaultConfiguration].allowRoundedArrow;
    CGFloat offset = 2.f * XCPopoverMenuDefaultMenuArrowRoundRadius * sinf(M_PI_4 / 2.f);
    CGFloat roundcenterHeight = offset + XCPopoverMenuDefaultMenuArrowRoundRadius * sqrtf(2.f);
    CGPoint roundcenterPoint = CGPointMake(anglePoint.x, roundcenterHeight);

    switch (_arrowDirection) {
        case XCPopoverMenuArrowDirectionUp: {

            if (allowRoundedArrow) {
                [path addArcWithCenter:CGPointMake(anglePoint.x + self.menuArrowWidth, self.menuArrowHeight - 2.f * XCPopoverMenuDefaultMenuArrowRoundRadius)
                                radius:2.f * XCPopoverMenuDefaultMenuArrowRoundRadius
                            startAngle:M_PI_2
                              endAngle:M_PI_4 * 3.f
                             clockwise:YES];
                [path addLineToPoint:CGPointMake(anglePoint.x + XCPopoverMenuDefaultMenuArrowRoundRadius / sqrtf(2.f),
                                                 roundcenterPoint.y - XCPopoverMenuDefaultMenuArrowRoundRadius / sqrtf(2.f))];
                [path addArcWithCenter:roundcenterPoint
                                radius:XCPopoverMenuDefaultMenuArrowRoundRadius
                            startAngle:M_PI_4 * 7.f
                              endAngle:M_PI_4 * 5.f
                             clockwise:NO];
                [path addLineToPoint:CGPointMake(anglePoint.x - self.menuArrowWidth + (offset * (1.f + 1.f / sqrtf(2.f))),
                                                 self.menuArrowHeight - offset / sqrtf(2.f))];
                [path addArcWithCenter:CGPointMake(anglePoint.x - self.menuArrowWidth, self.menuArrowHeight - 2.f * XCPopoverMenuDefaultMenuArrowRoundRadius)
                                radius:2.f * XCPopoverMenuDefaultMenuArrowRoundRadius
                            startAngle:M_PI_4
                              endAngle:M_PI_2
                             clockwise:YES];
            } else {
                [path moveToPoint:CGPointMake(anglePoint.x + self.menuArrowWidth, self.menuArrowHeight)];
                [path addLineToPoint:anglePoint];
                [path addLineToPoint:CGPointMake(anglePoint.x - self.menuArrowWidth, self.menuArrowHeight)];
            }

            [path addLineToPoint:CGPointMake(XCPopoverMenuDefaultMenuCornerRadius, self.menuArrowHeight)];
            [path addArcWithCenter:CGPointMake(XCPopoverMenuDefaultMenuCornerRadius, self.menuArrowHeight + XCPopoverMenuDefaultMenuCornerRadius)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:-M_PI_2
                          endAngle:-M_PI
                         clockwise:NO];
            [path addLineToPoint:CGPointMake(0, self.bounds.size.height - XCPopoverMenuDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(XCPopoverMenuDefaultMenuCornerRadius, self.bounds.size.height - XCPopoverMenuDefaultMenuCornerRadius)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:M_PI
                          endAngle:M_PI_2
                         clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width - XCPopoverMenuDefaultMenuCornerRadius,
                                             self.bounds.size.height)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - XCPopoverMenuDefaultMenuCornerRadius,
                                               self.bounds.size.height - XCPopoverMenuDefaultMenuCornerRadius)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:M_PI_2
                          endAngle:0
                         clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, XCPopoverMenuDefaultMenuCornerRadius + self.menuArrowHeight)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - XCPopoverMenuDefaultMenuCornerRadius,
                                               XCPopoverMenuDefaultMenuCornerRadius + self.menuArrowHeight)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:0
                          endAngle:-M_PI_2
                         clockwise:NO];
            [path closePath];

        } break;
        case XCPopoverMenuArrowDirectionDown: {

            roundcenterPoint = CGPointMake(anglePoint.x, anglePoint.y - roundcenterHeight);

            if (allowRoundedArrow) {
                [path addArcWithCenter:CGPointMake(anglePoint.x + self.menuArrowWidth, anglePoint.y - self.menuArrowHeight + 2.f * XCPopoverMenuDefaultMenuArrowRoundRadius)
                                radius:2.f * XCPopoverMenuDefaultMenuArrowRoundRadius
                            startAngle:M_PI_2 * 3
                              endAngle:M_PI_4 * 5.f
                             clockwise:NO];
                [path addLineToPoint:CGPointMake(anglePoint.x + XCPopoverMenuDefaultMenuArrowRoundRadius / sqrtf(2.f),
                                                 roundcenterPoint.y + XCPopoverMenuDefaultMenuArrowRoundRadius / sqrtf(2.f))];
                [path addArcWithCenter:roundcenterPoint
                                radius:XCPopoverMenuDefaultMenuArrowRoundRadius
                            startAngle:M_PI_4
                              endAngle:M_PI_4 * 3.f
                             clockwise:YES];
                [path addLineToPoint:CGPointMake(anglePoint.x - self.menuArrowWidth + (offset * (1.f + 1.f / sqrtf(2.f))),
                                                 anglePoint.y - self.menuArrowHeight + offset / sqrtf(2.f))];
                [path addArcWithCenter:CGPointMake(anglePoint.x - self.menuArrowWidth, anglePoint.y - self.menuArrowHeight + 2.f * XCPopoverMenuDefaultMenuArrowRoundRadius)
                                radius:2.f * XCPopoverMenuDefaultMenuArrowRoundRadius
                            startAngle:M_PI_4 * 7
                              endAngle:M_PI_2 * 3
                             clockwise:NO];
            } else {
                [path moveToPoint:CGPointMake(anglePoint.x + self.menuArrowWidth, anglePoint.y - self.menuArrowHeight)];
                [path addLineToPoint:anglePoint];
                [path addLineToPoint:CGPointMake(anglePoint.x - self.menuArrowWidth, anglePoint.y - self.menuArrowHeight)];
            }

            [path addLineToPoint:CGPointMake(XCPopoverMenuDefaultMenuCornerRadius, anglePoint.y - self.menuArrowHeight)];
            [path addArcWithCenter:CGPointMake(XCPopoverMenuDefaultMenuCornerRadius,
                                               anglePoint.y - self.menuArrowHeight - XCPopoverMenuDefaultMenuCornerRadius)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:M_PI_2
                          endAngle:M_PI
                         clockwise:YES];
            [path addLineToPoint:CGPointMake(0, XCPopoverMenuDefaultMenuCornerRadius)];
            [path addArcWithCenter:CGPointMake(XCPopoverMenuDefaultMenuCornerRadius, XCPopoverMenuDefaultMenuCornerRadius)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:M_PI
                          endAngle:-M_PI_2
                         clockwise:YES];
            [path addLineToPoint:CGPointMake(self.bounds.size.width - XCPopoverMenuDefaultMenuCornerRadius, 0)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - XCPopoverMenuDefaultMenuCornerRadius, XCPopoverMenuDefaultMenuCornerRadius)
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:-M_PI_2
                          endAngle:0
                         clockwise:YES];
            [path addLineToPoint:CGPointMake(self.bounds.size.width,
                                             anglePoint.y - (XCPopoverMenuDefaultMenuCornerRadius + self.menuArrowHeight))];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - XCPopoverMenuDefaultMenuCornerRadius,
                                               anglePoint.y - (XCPopoverMenuDefaultMenuCornerRadius + self.menuArrowHeight))
                            radius:XCPopoverMenuDefaultMenuCornerRadius
                        startAngle:0
                          endAngle:M_PI_2
                         clockwise:YES];
            [path closePath];

        } break;
        default:
            break;
    }

    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.lineWidth = [XCPopoverMenuConfiguration defaultConfiguration].borderWidth;
    _backgroundLayer.fillColor = [XCPopoverMenuConfiguration defaultConfiguration].tintColor.CGColor;
    _backgroundLayer.strokeColor = [XCPopoverMenuConfiguration defaultConfiguration].borderColor.CGColor;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [XCPopoverMenuConfiguration defaultConfiguration].menuRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuStringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id menuImage;
    if (_menuImageArray.count >= indexPath.row + 1) {
        menuImage = _menuImageArray[indexPath.row];
    }
    XCPopoverMenuCell *menuCell =
    [[XCPopoverMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:XCPopoverMenuTableViewCellIndentifier
                                           menuName:[NSString stringWithFormat:@"%@", _menuStringArray[indexPath.row]]
                                          menuImage:menuImage
                                       selectedCell:indexPath.row == self.selectedIndex];
    if (indexPath.row == _menuStringArray.count - 1) {
        menuCell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    } else {
        menuCell.separatorInset = UIEdgeInsetsMake(0, [XCPopoverMenuConfiguration defaultConfiguration].menuTextMargin,
                                                   0, [XCPopoverMenuConfiguration defaultConfiguration].menuTextMargin);
    }

    menuCell.layoutMargins = UIEdgeInsetsZero;
    menuCell.preservesSuperviewLayoutMargins = NO;
    if (indexPath.row == _menuImageArray.count - 1) {
        menuCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
    } else {
        menuCell.separatorInset = UIEdgeInsetsZero;
    }
    return menuCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.doneBlock) {
        self.doneBlock(indexPath.row);
    }
    self.selectedIndex = indexPath.row;
    [self.menuTableView reloadData];
}

@end

#pragma mark -XCPopoverMenu

@interface XCPopoverMenu() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) XCPopoverMenuView *popMenuView;
@property (nonatomic, strong) XCPopoverMenuDoneBlock doneBlock;
@property (nonatomic, strong) XCPopoverMenuDismissBlock dismissBlock;

@property (nonatomic, strong) UIView *sender;
@property (nonatomic, assign) CGRect senderFrame;
@property (nonatomic, strong) NSArray<NSString*> *menuArray;
@property (nonatomic, strong) NSArray<NSString*> *menuImageArray;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation XCPopoverMenu

- (void)showFromSender:(UIView *)sender
         withMenuArray:(NSArray<NSString *> *)menuArray
            imageArray:(NSArray *)imageArray
         selectedIndex:(NSInteger)selectedIndex
             doneBlock:(XCPopoverMenuDoneBlock)doneBlock
          dismissBlock:(XCPopoverMenuDismissBlock)dismissBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backgroundView addSubview:self.popMenuView];
        [[self backgroundWindow] addSubview:self.backgroundView];
        self.sender = sender;
        self.senderFrame = sender.frame;
        self.menuArray = menuArray;
        self.menuImageArray = imageArray;
        self.selectedIndex = selectedIndex;
        self.doneBlock = doneBlock;
        self.dismissBlock = dismissBlock;
        [self adjustPopOverMenu];
    });
}

#pragma mark - Private Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChangeStatusBarOrientationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (UIWindow *)backgroundWindow {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    if (window == nil && [delegate respondsToSelector:@selector(window)]) {
        window = [delegate performSelector:@selector(window)];
    }
    return window;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTapped:)];
        tap.delegate = self;
        [_backgroundView addGestureRecognizer:tap];
        _backgroundView.backgroundColor = XCPopoverMenuDefaultBackgroundColor;
    }
    return _backgroundView;
}

- (XCPopoverMenuView *)popMenuView {
    if (!_popMenuView) {
        _popMenuView = [[XCPopoverMenuView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _popMenuView.alpha = 0;
    }
    return _popMenuView;
}

- (CGFloat)menuArrowWidth {
    return [XCPopoverMenuConfiguration defaultConfiguration].allowRoundedArrow ? XCPopoverMenuDefaultMenuArrowWidth_R :
    XCPopoverMenuDefaultMenuArrowWidth;
}
- (CGFloat)menuArrowHeight {
    return [XCPopoverMenuConfiguration defaultConfiguration].allowRoundedArrow ? XCPopoverMenuDefaultMenuArrowHeight_R :
    XCPopoverMenuDefaultMenuArrowHeight;
}

- (void)onChangeStatusBarOrientationNotification:(NSNotification *)notification {
    if (self.isCurrentlyOnScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustPopOverMenu];
        });
    }
}

- (void)adjustPopOverMenu {

    [self.backgroundView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];

    CGRect senderRect;

    if (self.sender) {
        senderRect = [self.sender.superview convertRect:self.sender.frame toView:self.backgroundView];
        // if run into touch problems on nav bar, use the fowllowing line.
        //        senderRect.origin.y = MAX(64-senderRect.origin.y, senderRect.origin.y);
    } else {
        senderRect = self.senderFrame;
    }
    if (senderRect.origin.y > SCREEN_HEIGHT) {
        senderRect.origin.y = SCREEN_HEIGHT;
    }

    CGFloat menuHeight = [XCPopoverMenuConfiguration defaultConfiguration].menuRowHeight * self.menuArray.count + self.menuArrowHeight;
    CGPoint menuArrowPoint = CGPointMake(senderRect.origin.x + (senderRect.size.width) / 2, 0);
    CGFloat menuX = 0;
    CGRect menuRect = CGRectZero;
    BOOL shouldAutoScroll = NO;
    XCPopoverMenuArrowDirection arrowDirection;

    if (senderRect.origin.y + senderRect.size.height / 2 < SCREEN_HEIGHT / 2) {
        arrowDirection = XCPopoverMenuArrowDirectionUp;
        menuArrowPoint.y = 0;
    } else {
        arrowDirection = XCPopoverMenuArrowDirectionDown;
        menuArrowPoint.y = menuHeight;
    }

    if (menuArrowPoint.x + [XCPopoverMenuConfiguration defaultConfiguration].menuWidth / 2 + XCPopoverMenuDefaultMargin >
        SCREEN_WIDTH) {
        menuArrowPoint.x =
        MIN(menuArrowPoint.x - (SCREEN_WIDTH - [XCPopoverMenuConfiguration defaultConfiguration].menuWidth -
                                XCPopoverMenuDefaultMargin),
            [XCPopoverMenuConfiguration defaultConfiguration].menuWidth - self.menuArrowWidth - XCPopoverMenuDefaultMargin);
        menuX = SCREEN_WIDTH - [XCPopoverMenuConfiguration defaultConfiguration].menuWidth - XCPopoverMenuDefaultMargin;
    } else if (menuArrowPoint.x - [XCPopoverMenuConfiguration defaultConfiguration].menuWidth / 2 - XCPopoverMenuDefaultMargin < 0) {
        menuArrowPoint.x =
        MAX(XCPopoverMenuDefaultMenuCornerRadius + self.menuArrowWidth, menuArrowPoint.x - XCPopoverMenuDefaultMargin);
        menuX = XCPopoverMenuDefaultMargin;
    } else {
        menuArrowPoint.x = [XCPopoverMenuConfiguration defaultConfiguration].menuWidth / 2;
        menuX = senderRect.origin.x + (senderRect.size.width) / 2 - [XCPopoverMenuConfiguration defaultConfiguration].menuWidth / 2;
    }

    if (arrowDirection == XCPopoverMenuArrowDirectionUp) {
        menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height),
                              [XCPopoverMenuConfiguration defaultConfiguration].menuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y + menuRect.size.height > SCREEN_HEIGHT) {
            menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height),
                                  [XCPopoverMenuConfiguration defaultConfiguration].menuWidth,
                                  SCREEN_HEIGHT - menuRect.origin.y - XCPopoverMenuDefaultMargin);
            shouldAutoScroll = YES;
        }
    } else {

        menuRect = CGRectMake(menuX, (senderRect.origin.y - menuHeight),
                              [XCPopoverMenuConfiguration defaultConfiguration].menuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y < 0) {
            menuRect = CGRectMake(menuX, XCPopoverMenuDefaultMargin,
                                  [XCPopoverMenuConfiguration defaultConfiguration].menuWidth,
                                  senderRect.origin.y - XCPopoverMenuDefaultMargin);
            menuArrowPoint.y = senderRect.origin.y;
            shouldAutoScroll = YES;
        }
    }
    [self prepareToShowWithMenuRect:menuRect
                     menuArrowPoint:menuArrowPoint
                   shouldAutoScroll:shouldAutoScroll
                     arrowDirection:arrowDirection];

    [self show];
}

- (void)prepareToShowWithMenuRect:(CGRect)menuRect
                   menuArrowPoint:(CGPoint)menuArrowPoint
                 shouldAutoScroll:(BOOL)shouldAutoScroll
                   arrowDirection:(XCPopoverMenuArrowDirection)arrowDirection {
    CGPoint anchorPoint = CGPointMake(menuArrowPoint.x / menuRect.size.width, 0);
    if (arrowDirection == XCPopoverMenuArrowDirectionDown) {
        anchorPoint = CGPointMake(menuArrowPoint.x / menuRect.size.width, 1);
    }
    _popMenuView.transform = CGAffineTransformMakeScale(1, 1);

    @weakify(self);
    [_popMenuView showWithFrame:menuRect
                     anglePoint:menuArrowPoint
                  withNameArray:self.menuArray
                 imageNameArray:self.menuImageArray
                  selectedIndex:self.selectedIndex
               shouldAutoScroll:shouldAutoScroll
                 arrowDirection:arrowDirection
                      doneBlock:^(NSInteger selectedIndex) {
                          @strongify(self);
                          [self doneActionWithSelectedIndex:selectedIndex];
                      }];

    [self setAnchorPoint:anchorPoint forView:_popMenuView];

    _popMenuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint =
    CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);

    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);

    CGPoint position = view.layer.position;

    position.x -= oldPoint.x;
    position.x += newPoint.x;

    position.y -= oldPoint.y;
    position.y += newPoint.y;

    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:_popMenuView];
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    } else if (CGRectContainsPoint(CGRectMake(0, 0, [XCPopoverMenuConfiguration defaultConfiguration].menuWidth,
                                              [XCPopoverMenuConfiguration defaultConfiguration].menuRowHeight),
                                   point)) {
        [self doneActionWithSelectedIndex:0];
        return NO;
    }
    return YES;
}

#pragma mark - onBackgroundViewTapped

- (void)onBackgroundViewTapped:(UIGestureRecognizer *)gesture {
    [self dismiss];
}

#pragma mark - show animation

- (void)show {
    self.isCurrentlyOnScreen = YES;
    [UIView animateWithDuration:XCPopoverMenuDefaultAnimationDuration
                     animations:^{
                         _popMenuView.alpha = 1;
                         _popMenuView.transform = CGAffineTransformMakeScale(1, 1);
                     }];
}

#pragma mark - dismiss animation

- (void)dismiss {
    self.isCurrentlyOnScreen = NO;
    [self doneActionWithSelectedIndex:-1];
}

#pragma mark - doneActionWithSelectedIndex

- (void)doneActionWithSelectedIndex:(NSInteger)selectedIndex {
    [UIView animateWithDuration:XCPopoverMenuDefaultAnimationDuration
                     animations:^{
                         _popMenuView.alpha = 0;
                         _popMenuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self.popMenuView removeFromSuperview];
                             [self.backgroundView removeFromSuperview];
                             if (selectedIndex < 0) {
                                 if (self.dismissBlock) {
                                     self.dismissBlock();
                                 }
                             } else {
                                 if (self.doneBlock) {
                                     self.doneBlock(selectedIndex);
                                 }
                             }
                         }
                     }];
}

@end

