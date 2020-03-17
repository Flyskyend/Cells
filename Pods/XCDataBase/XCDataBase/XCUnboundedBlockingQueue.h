//
//  XCUnboundedBlockingQueue.h
//  XCDataBaseDemo
//
//  Created by wxc on 16/12/29.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCLinkedListNode;
@interface XCUnboundedBlockingQueue : NSObject {
    
@private
    pthread_mutex_t lock;
    pthread_cond_t notEmpty;
    XCLinkedListNode *first, *last;
}

- (void)put:(id)data;
- (id)take;
- (id)take:(int)timeout;
- (void)clear;

@end
