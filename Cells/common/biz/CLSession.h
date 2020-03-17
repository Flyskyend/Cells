//
//  CLSession.h
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLSession : NSObject

SYNTHESIZE_SINGLETON_FOR_HEADER(CLSession);

- (void)restore;

@end
