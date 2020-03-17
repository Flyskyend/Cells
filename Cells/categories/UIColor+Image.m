//
//  UIColor+Image.m
//  Cells
//
//  Created by 王新晨 on 2018/3/21.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "UIColor+Image.h"

@implementation UIColor (Image)

- (UIImage *)image {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
