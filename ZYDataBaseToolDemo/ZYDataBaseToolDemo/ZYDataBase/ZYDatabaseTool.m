//
//  ZYDataBase.m
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//

#import "ZYDatabaseTool.h"
#import "ZYDatabaseResult.h"
#import "FMDB.h"
#import "ZYDatabaseType.h"

@interface ZYDatabaseTool ()
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, weak) FMDatabase * transationDB;
@end

@implementation ZYDatabaseTool
@synthesize table = _table;
@synthesize insert = _insert;

#pragma mark - 初始化设置

+ (instancetype)sharedInstace
{
    static ZYDatabaseTool *_tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[self alloc] init];
    });
    return _tool;
}

- (void)createDatabase:(NSString *)databaseName createTableSqlFile:(NSString *)filepath
{
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:databaseName]];
    NSString *sql = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:NULL];
    if (sql.length) {
        [_databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:sql];
        }];
    }
}

#pragma mark - 执行sql前先指定要操作的表格

ZYDatabaseTool * ZYTable(NSString *tableName)
{
    return [ZYDatabaseTool new].table(tableName);
}

- (OneStringType)table
{
    if (_table == nil) {
        __weak typeof(self) weakSelf = self;
        _table = ^(NSString *str){
            weakSelf.tableName = str;
            return weakSelf;
        };
    }
    return _table;
}

#pragma mark - 执行函数(直接执行, 返回ZYDatabaseResult)

- (ExecuteDictType)insert
{
    if (_insert == nil) {
        __weak typeof(self) weakSelf = self;
        _insert = ^(NSDictionary *args){
            if (args.count) {
                NSString *sql = [weakSelf getInsertSqlWithArgs:args];
                [weakSelf executeUpdate:sql];
                NSLog(@"执行插入语句: %@", sql);
            }
            return [ZYDatabaseResult databaseResult:@YES];
        };
    }
    return _insert;
}

- (NSString *)getInsertSqlWithArgs:(NSDictionary *)args
{
    NSAssert(self.tableName != nil, @"请先指定要操作的表...");
    NSMutableString *sql = [NSMutableString stringWithFormat:@""];
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *sqlArgs = [NSMutableArray array];
    [args enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [values addObject:obj];
        [sqlArgs addObject:key];
    }];
    [sql appendString:InsertConst];
    [sql appendFormat:@"%@ ",self.tableName];
    [sql appendFormat:@"(%@) ", [sqlArgs componentsJoinedByString:@","]];
    [sql appendFormat:@"VALUES (%@);", [values componentsJoinedByString:@","]];
    return sql;
}

#pragma mark - 简化方法

- (void)executeUpdate:(NSString *)sql,...
{
    if (self.transationDB) {
        [self.transationDB executeUpdate:sql];
    }else{
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeUpdate:sql];
        }];
    }
}

#pragma mark - 附加操作

- (void)inTransaction:(void (^)(BOOL *))block
{
    [self.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        self.transationDB = db;
        block?block(rollback):NULL;
        self.transationDB = nil;
    }];
}

@end

