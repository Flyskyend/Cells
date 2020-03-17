//
//  CLCellDB.m
//  Cells
//
//  Created by 王新晨 on 2018/1/14.
//  Updated by 罗劭衡 on 2019/11/24.
//  Copyright © 2018年 wxc. All rights reserved.
//

#import "CLCell.h"
#import "CLBox.h"
#import "CLCellDB.h"
#import "CLTableVersionDB.h"
#import "NSDictionary+XCDBQuery.h"
#import "NSDictionary+XCCamelCaseKey.h"
#import <Bolts/Bolts.h>

static int const kTblVersionCell = 0;

static NSString * const kCellDB = @"cell.db";
static NSString * const kCellTbl = @"cellTbl";

@implementation CLCellDB

SYNTHESIZE_SINGLETON_FOR_CLASS(CLCellDB);

- (void)initStore:(NSString *)baseUrl {
    NSString *path = [baseUrl stringByAppendingPathComponent:kCellDB];
    [self initFMDatabase:path];
    @weakify(self);
    [[CLTableVersionDB sharedCLTableVersionDB]
    getTblVersionForDB:kCellDB
           finishBlock:^(NSDictionary *versions) {
               @strongify(self);
               FMDatabase *db = [[FMDatabase alloc] initWithPath:path];
               if ([db open]) {
                   if (!versions || !versions[kCellTbl] || (kTblVersionCell > [versions[kCellTbl] intValue])) {
                       [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", kCellTbl]];
                       [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cell_id integer primary key "
                                         @"autoincrement, name "
                                         @"varchar, create_time integer, box_id integer, box_index integer, note varchar)",
                                         kCellTbl]];
                       [[CLTableVersionDB sharedCLTableVersionDB] updateVersion:kTblVersionCell forTbl:kCellTbl inDB:kCellDB];
                   }
                   [db close];
                   static dispatch_once_t runOt;
                   dispatch_once(&runOt, ^{
                       [self run];
                   });
               }
           }];
}

- (void)cacheCell:(CLCell *)cell withFinishBlock:(void (^)(long long))finishBlock {
    //Flyskyend changed
    [self doWrite:[NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (name, create_time, box_id, box_index, note) values "
                                             @"(:name, :create_time, :box_id, :box_index, :note)",
                                             kCellTbl]
       withParams:@{
           @"name": cell.name,
           @"create_time": @(cell.createTime),
           @"box_id": @(cell.boxId),
           @"box_index": @(cell.boxIndex),
           @"note": cell.note,
       }
      finishBlock:finishBlock];
}

- (void)editCell:(CLCell *)cell withFinishBlock:(void (^)(long long))finishBlock {
    //Flyskyend changed
    [self doWrite:[NSString stringWithFormat:@"UPDATE %@ SET name=:name, create_time=:create_time, box_id=:box_id, "
                                             @"box_index=:box_index, note=:note WHERE cell_id=%@",
                                             kCellTbl, @(cell.cellId)]
       withParams:@{
           @"name": cell.name,
           @"create_time": @(cell.createTime),
           @"box_id": @(cell.boxId),
           @"box_index": @(cell.boxIndex),
           @"note": cell.note
       }
      finishBlock:finishBlock];
}

- (void)cacheCells:(NSArray<CLCell *> *)cells withFinishBlock:(void (^)(NSArray<CLCell *> *))finishBlock {
    NSMutableArray *tasks = @[].mutableCopy;
    NSMutableArray *cachedCells = @[].mutableCopy;
    for (CLCell *cell in cells) {
        BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
        [tasks addObject:tcs.task];
        [self cacheCell:cell
        withFinishBlock:^(long long lastId) {
            cell.cellId = lastId;
            [cachedCells addObject:cell];
            [tcs setResult:@1];
        }];
    }
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                           withBlock:^id _Nullable(BFTask *_Nonnull t) {
                                                               if (finishBlock) {
                                                                   finishBlock(cachedCells);
                                                               }
                                                               return nil;
                                                           }];
}

- (void)getCellsWithFinishBlock:(void (^)(NSArray<CLCell *> *))finishBlock {
    [self getCellsWithCond:nil finishBlock:finishBlock];
}

- (void)getCellsWithCond:(NSDictionary *)conds finishBlock:(void (^)(NSArray<CLCell *> *))finishBlock {
    NSDictionary *formatCond = conds ? [conds queryCond] : [@{} queryCond];
    [self doRead:[NSString stringWithFormat:@"SELECT * FROM %@%@", kCellTbl, [formatCond objectForKey:kDBCondStr]]
      withParams:[formatCond objectForKey:kDBCondValue]
     finishBlock:^(NSArray *res) {
         NSArray *cells = [MTLJSONAdapter
         modelsOfClass:[CLCell class]
         fromJSONArray:[[[res rac_sequence] map:^id(NSDictionary *metaData) {
             //Flyskyend changed
             return
             [[metaData dictionaryWithValuesForKeys:@[@"cell_id", @"name", @"create_time", @"box_id", @"box_index", @"note"]] camelCase];
         }] array]
                 error:nil];
         finishBlock(cells);
     }];
}

- (BFTask *)deleteCell:(CLCell *)cell {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [self doWrite:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cell_id=:cell_id", kCellTbl]
    withParams:@{
        @"cell_id": @(cell.cellId)
    }
    finishBlock:^(long long lastId) {
        [tcs setResult:@(lastId)];
    }];
    return tcs.task;
}

- (BFTask *)deleteCellsFromBox:(CLBox *)box {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [self doWrite:[NSString stringWithFormat:@"DELETE FROM %@ WHERE box_id=:box_id", kCellTbl]
    withParams:@{
        @"box_id": @(box.bid)
    }
    finishBlock:^(long long lastId) {
        [tcs setResult:@(lastId)];
    }];
    return tcs.task;
}

@end
