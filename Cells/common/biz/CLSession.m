//
//  CLSession.m
//  Cells
//
//  Created by 王新晨 on 2018/1/12.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLSession.h"
#import "CLCanisterDB.h"
#import "CLBasketDB.h"
#import "CLBoxDB.h"
#import "CLCellDB.h"
#import "CLTableVersionDB.h"

static NSString * const kUserDB = @"userDB";

@implementation CLSession

SYNTHESIZE_SINGLETON_FOR_CLASS(CLSession);

- (void)restore {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *commonPath = paths[0];
    //NSLog(@"\n---------CommonPath:%@",commonPath);
    NSString *dbPath = [commonPath stringByAppendingPathComponent:kUserDB];
    //NSLog(@"\n---------dbPath:%@",dbPath);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        return;
    }
    [[CLTableVersionDB sharedCLTableVersionDB] initStore:dbPath];
    [[CLCanisterDB sharedCLCanisterDB] initStore:dbPath];
    [[CLBasketDB sharedCLBasketDB] initStore:dbPath];
    [[CLBoxDB sharedCLBoxDB] initStore:dbPath];
    [[CLCellDB sharedCLCellDB] initStore:dbPath];
}

@end
