//
//  CLCell.h
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Uptated by 罗劭衡 on 2019/11/24.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CLCell : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) long cellId;
@property (nonatomic, assign) long boxId;
@property (nonatomic, assign) int boxIndex;
@property (nonatomic, assign) long createTime;
@property (nonatomic, copy) NSString *note;

@end
