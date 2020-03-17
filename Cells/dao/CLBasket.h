//
//  CLBasket.h
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Uptated by 罗劭衡 on 2019/11/27.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CLBasket : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) long bid;
@property (nonatomic, assign) long canisterId;
@property (nonatomic, assign) long createTime;
@property (nonatomic, copy) NSString *note;

@end
