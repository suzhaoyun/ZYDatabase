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
@synthesize first = _first;
@synthesize all = _all;

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

- (void)createDatabase:(NSString *)databaseName createTableSqlFilePath:(NSString *)filepath
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
    return [ZYDatabaseTool sharedInstace].table(tableName);
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
            BOOL result = NO;
            if (args.count) {
                NSString *sql = [weakSelf getInsertSqlWithArgs:args];
                result = [weakSelf executeUpdate:sql];
                if (result){
                    NSLog(@"成功执行插入语句: %@", sql);
                }
            }
            return [ZYDatabaseResult databaseResult:@(result)];
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
        [values addObject:[NSString stringWithFormat:@"'%@'", obj]];
        [sqlArgs addObject:key];
    }];
    [sql appendString:InsertConst];
    [sql appendFormat:@"%@ ",self.tableName];
    [sql appendFormat:@"(%@) ", [sqlArgs componentsJoinedByString:@","]];
    [sql appendFormat:@"VALUES (%@);", [values componentsJoinedByString:@","]];
    return sql;
}

#pragma mark - 简化方法

- (BOOL)executeUpdate:(NSString *)sql,...
{
    __block BOOL result;
    if (self.transationDB) {
        result = [self.transationDB executeUpdate:sql];
    }else{
        
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            result = [db executeUpdate:sql];
        }];
    }
    return result;
}

- (ExecuteStringType)first
{
    if (_first == nil) {
        __weak typeof(self) weakSelf = self;
        _first = ^(NSString *str){
            return [ZYDatabaseResult new];
        };
    }
    return _first;
}

- (ExecuteType)all
{
    if (_all == nil) {
        __weak typeof(self) weakSelf = self;
        _all = ^{
            if (self.tableName == nil) {
                return [ZYDatabaseResult new];
            }
            NSString *sql = [NSString stringWithFormat:@"%@* FROM %@;", SelectConst, weakSelf.tableName];
            __block FMResultSet *result = nil;
            if (weakSelf.transationDB) {
                result = [weakSelf.transationDB executeQuery:sql];
            }else{
                [weakSelf.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    result = [db executeQuery:sql];
                    [result close];
                }];
            }
            
            NSMutableArray *arrM;
//            = [weakSelf getResult:result];
            
            return [ZYDatabaseResult databaseResult:arrM];
        };
    }
    return _all;
}

- (NSMutableArray *)getResult:(FMResultSet *)set
{
    NSMutableArray *results = [NSMutableArray array];
    while (set.next) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        int columnCount = [set columnCount];
        for (int i = 0; i < columnCount; i++) {
            NSString *columnName = [set columnNameForIndex:i];
            id obj = [set objectForColumnIndex:i];
            if ([obj isKindOfClass:[NSNull class]] || obj == nil) {
                continue;
            }
            [result setObject:obj forKey:columnName];
        }
        [results addObject:result];
    }
    [set close];
    return results;
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

