//
//  ZYDataBase.m
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//

#import "ZYDatabaseTool.h"
#import "FMDB.h"
#import "ZYDatabaseType.h"

//处理日志打印在正式环境下的资源消耗问题
#ifdef DEBUG
#define ZYLog(...) NSLog(__VA_ARGS__)
#else
#define ZYLog(...)
#endif

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

@interface ZYDatabaseTool ()
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, weak) FMDatabase * transationDB;
@property (nonatomic, strong) NSMutableArray *whereConditions;
@end

@implementation ZYDatabaseTool
@synthesize table = _table;
@synthesize insert = _insert;
@synthesize update = _update;
@synthesize delete = _delete;
@synthesize where = _where;
@synthesize andWhere = _andWhere;
@synthesize orWhere = _orWhere;
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

- (OneStringType)table
{
    if (_table == nil) {
        WeakSelf
        _table = ^(NSString *str){
            StrongSelf
            strongSelf.tableName = str;
            return weakSelf;
        };
    }
    return _table;
}

#pragma mark - 执行函数(直接执行, 返回ZYDatabaseResult)

/** 插入方法 */
- (InsertUpdateType)insert
{
    if (_insert == nil) {
        WeakSelf
        _insert = ^(NSDictionary *args){
            StrongSelf
            BOOL result = NO;
            if (args.count > 0) {
                NSString *sql = [strongSelf getInsertSqlWithArgs:args];
                result = [strongSelf executeUpdate:sql];
            }else{
                ZYLog(@"插入失败, 参数不能为空!!");
            }
            return result;
        };
    }
    return _insert;
}

- (NSString *)getInsertSqlWithArgs:(NSDictionary *)args
{
    NSAssert(self.tableName != nil, @"请先指定要操作的表...");
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@%@ ", InsertConst, self.tableName];
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *sqlArgs = [NSMutableArray array];
    [args enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [values addObject:[NSString stringWithFormat:@"'%@'", obj]];
        [sqlArgs addObject:key];
    }];
    [sql appendFormat:@"(%@) ", [sqlArgs componentsJoinedByString:@","]];
    [sql appendFormat:@"VALUES (%@);", [values componentsJoinedByString:@","]];
    ZYLog(@"%@", sql);
    return sql;
}

/** 更新方法 */
- (InsertUpdateType)update
{
    if (_update == nil) {
        WeakSelf
        _update = ^(NSDictionary *args){
            StrongSelf
            BOOL result = NO;
            if (args.count > 0) {
                result = [strongSelf executeUpdate:[strongSelf getUpdateSql:args]];
            }else{
                ZYLog(@"更新失败, 参数不能为空");
            }
            return NO;
        };
    }
    return _update;
}

- (NSString *)getUpdateSql:(NSDictionary *)args
{
    NSAssert(self.tableName != nil, @"请先指定要操作的表...");
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@%@ SET ", UpdateConst, self.tableName];
    NSArray *keys = args.allKeys;
    for (NSUInteger i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        [sql appendFormat:@"%@ = '%@'", key, [args objectForKey:key]];
        if (i < keys.count - 1) {
            [sql appendString:@", "];
        }else{
            [sql appendString:@" "];
        }
    }
    
    // 添加筛选条件
    [sql appendFormat:@"%@;", [self getWhereSql]];
    ZYLog(@"%@", sql);
    return sql;
}

/** 删除方法 */
- (DeleteType)delete
{
    if (_delete == nil) {
        WeakSelf
        _delete = ^{
            StrongSelf
            return [strongSelf executeUpdate:[strongSelf getDeleteSql]];
        };
    }
    return _delete;
}

- (NSString *)getDeleteSql
{
    NSAssert(self.tableName != nil, @"请先指定要操作的表...");
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@%@ ", DeleteConst, self.tableName];
    [sql appendFormat:@"%@;", [self getWhereSql]];
    ZYLog(@"%@", sql);
    return sql;
}

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

/** where条件 */
- (OneObjectType)where
{
    if (_where == nil) {
        WeakSelf
        _where = ^(id args){
            StrongSelf
            if (args){
                [strongSelf.whereConditions addObject:@{@"Type" : @"AND", @"Content" : args}];
            }
            return strongSelf;
        };
    }
    return _where;
}

- (OneObjectType)andWhere
{
    if (_andWhere == nil) {
        WeakSelf
        _andWhere = ^(id args){
            StrongSelf
            if (args){
                [strongSelf.whereConditions addObject:@{@"Type" : @"AND", @"Content" : args}];
            }
            return strongSelf;
        };
    }
    return _andWhere;
}

- (OneObjectType)orWhere
{
    if (_orWhere == nil) {
        WeakSelf
        _orWhere = ^(id args){
            StrongSelf
            if (args){
                [strongSelf.whereConditions addObject:@{@"Type" : @"OR", @"Content" : args}];
            }
            return strongSelf;
        };
    }
    return _orWhere;
}

- (NSString *)getWhereSql
{
    NSMutableString *sql = [NSMutableString string];
    if (self.whereConditions.count == 0) {
        return sql;
    }
    
    // 纠正条件顺序  防止第一个语句有多个条件但第一个条件是OR
    [self.whereConditions sortUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull obj1, NSDictionary *  _Nonnull obj2) {
        NSString *type1 = [obj1 objectForKey:@"Type"];
        NSString *type2 = [obj2 objectForKey:@"Type"];
        
        if ([type1 isEqualToString:@"AND"] && ![type2 isEqualToString:@"AND"]) {
            return NSOrderedAscending;
        }
        else if (![type1 isEqualToString:@"AND"] && [type2 isEqualToString:@"AND"]){
            return NSOrderedDescending;
        }
        else{
            return NSOrderedSame;
        }

    }];
    
    [sql appendString:WhereConst];
    
    for (NSUInteger  i = 0; i < self.whereConditions.count; i++) {
        NSDictionary *whereArgs = self.whereConditions[i];
        NSString *type = [whereArgs objectForKey:@"Type"];
        
        id args = [whereArgs objectForKey:@"Content"];
        
        NSMutableString *contentSql = [NSMutableString string];
        
        if ([args isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = args;
            NSArray *allkeys = dict.allKeys;
            for (NSUInteger i = 0; i < allkeys.count; i++) {
                NSString *key = allkeys[i];
                [contentSql appendFormat:@"%@ = '%@'", key, [dict objectForKey:key]];
                if (i < allkeys.count - 1) {
                    [contentSql appendString:@" AND "];
                }
            }
        }
        else if ([args isKindOfClass:[NSArray class]]) {
            NSArray *arr = args;
            NSAssert(arr.count % 3 == 0, @"%@where参数有问题,参数个数必须是3的倍数", arr);
            if (arr.count == 0) {
                continue;
            }
            
            for (NSUInteger i = 0; i < arr.count; i++) {
                NSInteger index = (i + 1) % 3;
                if (index == 1) {
                    [contentSql appendFormat:@"%@ ", arr[i]];
                }
                else if (index == 2){
                    [contentSql appendFormat:@"%@ ", arr[i]];
                }
                else{
                    [contentSql appendFormat:@"'%@'", arr[i]];
                    
                    if (i < arr.count - 1) {
                        [contentSql appendString:@" AND "];
                    }
                }
            }
        }
        else if ([args isKindOfClass:[NSString class]]){
            NSString *strArgs = args;
            if (strArgs.length) {
                [contentSql appendFormat:@"%@", strArgs];
            }
        }
        
        // 添加类型符号
        if (contentSql.length > 0) {
            if (i != 0) {
                [sql appendFormat:@" %@ ", type];
            }
            [sql appendFormat:@"(%@)", contentSql];
        }
    }
    
    return sql;
}

#pragma mark - 简化方法


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

- (NSMutableArray *)whereConditions
{
    if (_whereConditions == nil) {
        _whereConditions = [NSMutableArray array];
    }
    return _whereConditions;
}

@end

