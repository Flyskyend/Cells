//
//  XCLinkedListNode.h
//  XCDataBaseDemo
//
//  Created by wxc on 16/12/29.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCLinkedListNode : NSObject

@property (nonatomic, strong) id data;
@property (nonatomic, strong) XCLinkedListNode* next;

@end
