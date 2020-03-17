//
//  CLBox.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CLBox : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) long bid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int row;
@property (nonatomic, assign) int column;
@property (nonatomic, assign) long basketId;
@property (nonatomic, assign) long createTime;
@property (nonatomic, copy) NSString *note;


@end
