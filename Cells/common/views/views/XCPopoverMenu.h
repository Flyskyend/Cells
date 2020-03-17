//
//  XCPopoverMenu.h
//  Cells
//
//  Created by 王新晨 on 2018/3/17.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^XCPopoverMenuDoneBlock)(NSInteger selectedIndex);
typedef void (^XCPopoverMenuDismissBlock)();

@interface XCPopoverMenuConfiguration : NSObject

@property (nonatomic, assign) CGFloat menuTextMargin; // Default is 6.
@property (nonatomic, assign) CGFloat menuIconMargin; // Default is 6.
@property (nonatomic, assign) CGFloat menuRowHeight;
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) NSTextAlignment textAlignment;
// Default is 'NO', if sets to 'YES', images color will be same as textColor.
@property (nonatomic, assign) BOOL ignoreImageOriginalColor;

// Default is 'NO', if sets to 'YES', the arrow will be drawn with round corner.
@property (nonatomic, assign) BOOL allowRoundedArrow;

@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 *  defaultConfiguration
 *
 *  @return curren configuration
 */
+ (XCPopoverMenuConfiguration *)defaultConfiguration;

@end

@interface XCPopoverMenuCell : UITableViewCell

@end

@interface XCPopoverMenuView : UIControl

@end

@interface XCPopoverMenu : NSObject

- (void)showFromSender:(UIView *)sender
         withMenuArray:(NSArray<NSString *> *)menuArray
            imageArray:(NSArray *)imageArray
         selectedIndex:(NSInteger)selectedIndex
             doneBlock:(XCPopoverMenuDoneBlock)doneBlock
          dismissBlock:(XCPopoverMenuDismissBlock)dismissBlock;

@end

