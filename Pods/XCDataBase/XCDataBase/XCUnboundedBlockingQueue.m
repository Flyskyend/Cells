//
//  XCUnboundedBlockingQueue.m
//  XCDataBaseDemo
//
//  Created by wxc on 16/12/29.
//  Copyright © 2016年 wxc. All rights reserved.
//

#import "XCLinkedListNode.h"
#import "XCUnboundedBlockingQueue.h"
#import <pthread/pthread.h>
#import <sys/time.h>

@implementation XCUnboundedBlockingQueue

- (instancetype)init {
    if ((self = [super init])) {
        last = nil;
        first = nil;
        pthread_mutex_init(&lock, NULL);
        pthread_cond_init(&notEmpty, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_cond_destroy(&notEmpty);
    pthread_mutex_destroy(&lock);
}

- (void)put:(id)data {
    pthread_mutex_lock(&lock);
    XCLinkedListNode *n = [[XCLinkedListNode alloc] init];
    n.data = data;
    
    if (last != nil) {
        last.next = n;
    }
    if (first == nil) {
        first = n;
    }
    
    last = n;
    
    pthread_cond_signal(&notEmpty);
    pthread_mutex_unlock(&lock);
}

- (id)take {
    id data = nil;
    
    pthread_mutex_lock(&lock);
    
    while (first == nil) {
        pthread_cond_wait(&notEmpty, &lock);
    }
    data = first.data;
    first = first.next;
    if (first == nil) {
        last = nil; // Empty queue
    }
    
    pthread_mutex_unlock(&lock);
    return data;
}

- (id)take:(int)timeout {
    id data = nil;
    struct timespec ts;
    struct timeval now;
    
    pthread_mutex_lock(&lock);
    
    gettimeofday(&now, NULL);
    
    ts.tv_sec = now.tv_sec + timeout;
    ts.tv_nsec = 0;
    
    while (first == nil) {
        if (pthread_cond_timedwait(&notEmpty, &lock, &ts) != 0) {
            pthread_mutex_unlock(&lock);
            return nil;
        }
    }
    data = first.data;
    first = first.next;
    if (first == nil) {
        last = nil; // Empty queue
    }
    
    pthread_mutex_unlock(&lock);
    return data;
}

- (void)clear {
    pthread_mutex_lock(&lock);
    do {
        if (first == nil) {
            last = nil; // Empty queue
            break;
        }
        first = first.next;
    } while (true);
    
    pthread_mutex_unlock(&lock);
}

@end
