//
//  ZYDataBase.m
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//

#import "ZYDatabaseHandler.h"
#import "FMDB.h"

//处理日志打印在正式环境下的资源消耗问题

#ifdef DEBUG
#define ZYLog(...) NSLog(__VA_ARGS__)
#else
#define ZYLog(...)
#endif

#ifndef WeakSelf
#define WeakSelf __weak typeof(self) weakSelf = self;
#endif

#ifndef StrongSelf
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;
#endif

@interface ZYDatabaseHandler ()
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, weak) FMDatabase * transationDB;
@property (nonatomic, strong) NSMutableArray *whereConditions;
@property (nonatomic, strong) NSMutableArray *joinConditions;
@property (nonatomic, assign) BOOL distinctCondition;
@property (nonatomic, copy) NSString *limitCondition;
@property (nonatomic, strong) NSString *havingCondition;
@property (nonatomic, strong) id selectCondition;
@property (nonatomic, strong) NSMutableArray *orderByConditions;
@property (nonatomic, copy) NSString *groupByCondition;
@property (nonatomic, strong) NSMutableArray *arguments;
@property (nonatomic, copy) FilterMapArgsType filtermapargs;
@end

@implementation ZYDatabaseHandler
// 为了懒加载, 只能重写get方法. 但是只读属性如果实现了get方法,就不会自动生成_下划线变量了.需要手动合成
@synthesize table = _table;
@synthesize create = _create;
@synthesize drop = _drop;
@synthesize alter = _alter;
@synthesize insert = _insert;
@synthesize update = _update;
@synthesize delete = _delete;
@synthesize where = _where;
@synthesize andWhere = _andWhere;
@synthesize orWhere = _orWhere;
@synthesize first = _first;
@synthesize all = _all;
@synthesize filtermap = _filtermap;
@synthesize limit = _limit;
@synthesize select = _select;
@synthesize orderBy = _orderBy;
@synthesize groupBy = _groupBy;
@synthesize having = _having;
@synthesize leftJoin = _leftJoin;
@synthesize join = _join;
@synthesize rightJoin = _rightJoin;
@synthesize distinct = _distinct;
@synthesize count = _count;

#pragma mark - 初始化设置

ZYDatabaseHandler * Table(NSString *table)
{
    return [ZYDatabaseHandler sharedInstace].table(table);
}

+ (instancetype)sharedInstace
{
    static ZYDatabaseHandler *_tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[self alloc] init];
    });
    return _tool;
}

- (void)createDatabaseWithPath:(NSString *)databasePath
{
    NSAssert(databasePath.length>0, @"databasePath不能为null");
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
}

#pragma mark - 执行sql前先指定要操作的表格

- (OneStringType)table
{
    if (_table == nil) {
        WeakSelf
        _table = ^(NSString *str){
            StrongSelf
            // 重置条件重新指定表名
            [strongSelf resetSql];
            strongSelf.tableName = str;
            return strongSelf;
        };
    }
    return _table;
}

#pragma mark - 表操纵函数(直接执行)

- (DDLType)create
{
    if (_create == nil) {
        WeakSelf
        _create = ^(NSString *sql){
            StrongSelf
            return [strongSelf executeUpdate:[NSString stringWithFormat:@"%@%@ (%@);", CreateConst, strongSelf.tableName, sql]];
        };
    }
    return _create;
}

- (VoidType)drop
{
    if (_drop == nil) {
        WeakSelf
        _drop = ^{
            StrongSelf
            return [strongSelf executeUpdate:[NSString stringWithFormat:@"%@%@;", DropConst, strongSelf.tableName]];
        };
    }
    return _drop;
}

- (DDLType)alter
{
    if (_alter == nil) {
        WeakSelf
        _alter = ^(NSString *sql){
            StrongSelf
            return [strongSelf executeUpdate:[NSString stringWithFormat:@"%@%@ %@;", AlterConst, strongSelf.tableName, sql]];
        };
    }
    return _alter;
}

#pragma mark - 执行函数(直接执行)

/** 插入方法 */
- (InsertUpdateType)insert
{
    if (_insert == nil) {
        WeakSelf
        _insert = ^(NSDictionary *args){
            StrongSelf
            BOOL result = NO;
            if (args.count > 0) {
                // 根据参数生成sql
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
    // 对空值进行特殊处理
    [args enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [values addObject:@"null"];
        }else{
            [values addObject:@"?"];
            [self.arguments addObject:obj];
        }
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
        NSString *obj = [args objectForKey:key];
        
        // 如果是空值
        if ([obj isKindOfClass:[NSNull class]]) {
            [sql appendFormat:@"%@ = null", key];
        }else{
            // 如果是字符串 需要校验是否已经包含''
            if ([obj isKindOfClass:[NSString class]]) {
                if ([obj hasPrefix:@"'"] && [obj hasSuffix:@"'"]) {
                    obj = [obj substringWithRange:NSMakeRange(1, obj.length-1)];
                }
            }
            [sql appendFormat:@"%@ = '%@'", key, obj];
        }
        // 添加分割符号
        if (i < keys.count - 1) {
            [sql appendString:@", "];
        }else{
            [sql appendString:@" "];
        }
    }
    
    // 添加筛选条件
    [sql appendFormat:@"%@;", [self getConditionSql]];
    ZYLog(@"%@", sql);
    return sql;
}

/** 删除方法 */
- (VoidType)delete
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
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@%@", DeleteConst, self.tableName];
    NSString *whereSql = [self getConditionSql];
    if (whereSql.length) {
        [sql appendFormat:@" %@", whereSql];
    }
    [sql appendString:@";"];
    ZYLog(@"%@", sql);
    return sql;
}

- (BOOL)executeUpdate:(NSString *)sql
{
    __block BOOL result;
    // 如果当前在transactionDB中
    if (self.transationDB) {
        result = [self.transationDB executeUpdate:sql withArgumentsInArray:self.arguments];
    }else{
        [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            result = [db executeUpdate:sql withArgumentsInArray:self.arguments];
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

/** group by 分组*/
- (OneStringType)groupBy
{
    if (_groupBy == nil) {
        WeakSelf
        _groupBy = ^(NSString *sql){
            StrongSelf
            strongSelf.groupByCondition = sql;
            return strongSelf;
        };
    }
    return _groupBy;
}

/** having条件 */
- (OneStringType)having
{
    if (_having == nil) {
        WeakSelf
        _having = ^(NSString *rawSql){
            StrongSelf
            if (rawSql.length){
                strongSelf.havingCondition = rawSql;
            }
            return strongSelf;
        };
    }
    return _having;
}

- (NSString *)getConditionSql
{
    NSMutableString *sql = [NSMutableString string];
    if (self.whereConditions.count == 0) {
        return sql;
    }
    
    // 纠正条件顺序  防止第一个语句有多个条件但第一个条件是OR
    [self sortWhereApi];
    
    [sql appendString:WhereConst];
    
    for (NSUInteger  i = 0; i < self.whereConditions.count; i++) {
        NSDictionary *whereArgs = self.whereConditions[i];
        NSString *type = [whereArgs objectForKey:@"Type"];
        
        id args = [whereArgs objectForKey:@"Content"];
        
        NSString *contentSql = [self getWhereCondition:args];
        
        // 添加类型符号
        if (contentSql.length > 0) {
            if (i != 0) {
                [sql appendFormat:@" %@ ", type];
            }
            [sql appendFormat:@"%@", contentSql];
        }
    }
    
    return [sql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)sortWhereApi
{
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
}

- (NSString *)getWhereCondition:(id)args
{
    NSMutableString *contentSql = [NSMutableString string];
    
    if ([args isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = args;
        NSArray *allkeys = dict.allKeys;
        for (NSUInteger i = 0; i < allkeys.count; i++) {
            NSString *key = allkeys[i];
            id obj = [dict objectForKey:key];
            if ([obj isKindOfClass:[NSNull class]]) {
                [contentSql appendFormat:@"%@ = null", key];
            }
            else{
                [contentSql appendFormat:@"%@ = ?", key];
                [self.arguments addObject:obj];
            }
            if (i < allkeys.count - 1) {
                [contentSql appendString:@" AND "];
            }
        }
    }
    else if ([args isKindOfClass:[NSArray class]]) {
        NSArray *arr = args;
        NSAssert(arr.count % 3 == 0, @"%@%@参数有问题,参数个数必须是3的倍数", arr, @"where");
        if (arr.count == 0) {
            return nil;
        }
        
        for (NSUInteger i = 0; i < arr.count; i++) {
            NSInteger index = (i + 1) % 3;
            id obj = arr[i];
            if (index == 1) {
                [contentSql appendFormat:@"%@ ", obj];
            }
            else if (index == 2){
                [contentSql appendFormat:@"%@ ", obj];
            }
            // 第三个参数
            else{
                if ([obj isKindOfClass:[NSNull class]]) {
                    [contentSql appendString:@"null"];
                }
                // 如果是数组 可能是in条件
                else if ([obj isKindOfClass:[NSArray class]]) {
                    NSString *values = [self getValuesString:obj];
                    if (values.length > 0) {
                        [contentSql appendFormat:@"(%@)", values];
                    }
                }
                else{
                    [contentSql appendString:@"?"];
                    [self.arguments addObject:obj];
                }
                
                if (i < arr.count - 1) {
                    [contentSql appendString:@" AND "];
                }
            }
        }
    }
    // 高级where语句 必须加括号
    else if ([args isKindOfClass:[NSString class]]){
        NSString *strArgs = args;
        if (strArgs.length) {
            [contentSql appendFormat:@"(%@)", strArgs];
        }
    }
    return contentSql;
}

- (NSString *)getValuesString:(NSArray *)array
{
    NSMutableString *inObjSql = [NSMutableString string];
    for (NSUInteger j = 0; j < array.count; j++) {
        id ob = array[j];
        if ([ob isKindOfClass:[NSString class]]) {
            [inObjSql appendFormat:@"'%@'", ob];
        }
        if (j < array.count - 1) {
            [inObjSql appendString:@","];
        }
    }
    return inObjSql;
}

/** 查询方法 */

- (FirstType)first
{
    if (_first == nil) {
        WeakSelf
        _first = ^{
            StrongSelf
            return strongSelf.limit(@"0, 1").all().firstObject;
        };
    }
    return _first;
}

- (MutipleType)all
{
    if (_all == nil) {
        WeakSelf
        _all = ^{
            StrongSelf
            NSMutableArray *results = [NSMutableArray array];
            __block FMResultSet *set = nil;
            if (strongSelf.transationDB) {
                set = [strongSelf.transationDB executeQuery:[strongSelf getQuerySql] withArgumentsInArray:self.arguments];
                [results addObjectsFromArray:[strongSelf getResult:set]];
                [set close];
            }else{
                [strongSelf.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    set = [db executeQuery:[strongSelf getQuerySql] withArgumentsInArray:self.arguments];
                    [results addObjectsFromArray:[strongSelf getResult:set]];
                    [set close];
                }];
            }
            return results;
        };
    }
    return _all;
}

- (CountType)count
{
    if (_count == nil) {
        WeakSelf
        _count = ^{
            StrongSelf
            return [[strongSelf.select(@"count(*) as count").first() objectForKey:@"count"] integerValue];
        };
    }
    return _count;
}

- (DistinctType)distinct
{
    if (_distinct == nil) {
        WeakSelf
        _distinct = ^{
            StrongSelf
            strongSelf.distinctCondition = YES;
            return strongSelf;
        };
    }
    return _distinct;
}

- (OneObjectType)select
{
    if (_select == nil) {
        WeakSelf
        _select = ^(id args){
            StrongSelf
            strongSelf.selectCondition = args;
            return strongSelf;
        };
    }
    return _select;
}

- (NSString *)getQuerySql
{
    NSAssert(self.tableName.length > 0, @"请先指定要操作的表...");
    
    NSMutableString *sql = [NSMutableString stringWithString:SelectConst];
    
    // 添加去重语句
    if (self.distinctCondition) {
        [sql appendString:DistinctConst];
    }
    
    // 拼接select语句
    NSString *selectSql = @"*";
    if (self.selectCondition) {
        if ([self.selectCondition isKindOfClass:[NSString class]]) {
            selectSql = self.selectCondition;
        }
        else if ([self.selectCondition isKindOfClass:[NSArray class]]){
            selectSql = [(NSArray *)self.selectCondition componentsJoinedByString:@","];
        }
    }
    [sql appendFormat:@"%@ ", selectSql];
    
    // 拼接table语句
    NSMutableString *tableSql = [NSMutableString stringWithString:self.tableName];
    [sql appendFormat:@"FROM %@ ", tableSql];
    
    // 拼接连表语句
    for (NSString *joinSql in self.joinConditions) {
        [sql appendFormat:@"%@ ", joinSql];
    }
    
    // 拼接where条件
    NSString *whereSql = [self getConditionSql];
    if (whereSql.length) {
        [sql appendFormat:@"%@ ", whereSql];
    }
    
    // 拼接group by 语句 having字句
    if (self.groupByCondition.length) {
        [sql appendFormat:@"%@%@ ", GroupByConst, self.groupByCondition];
        
        if (self.havingCondition.length) {
            [sql appendFormat:@"%@ %@ ", HavingConst, self.havingCondition];
        }
    }
    
    // 拼接order by 条件
    if (self.orderByConditions.count) {
        [sql appendString:OrderByConst];
        for (NSUInteger i = 0; i < self.orderByConditions.count; i++) {
            NSDictionary *dict = self.orderByConditions[i];
            [sql appendFormat:@"%@ %@", [dict objectForKey:@"column"], [dict objectForKey:@"sortType"]];
            if (i < self.orderByConditions.count - 1) {
                [sql appendString:@", "];
            }
        }
        [sql appendString:@" "];
    }
    
    // 拼接limit语句
    if (self.limitCondition.length) {
        [sql appendFormat:@"LIMIT %@", self.limitCondition];
    }
    
    sql = [NSMutableString stringWithFormat:@"%@;", [sql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    ZYLog(@"sql : %@", sql);
    
    return sql;
}

- (OrderByType)orderBy
{
    if (_orderBy == nil) {
        WeakSelf
        _orderBy = ^(NSString *column, NSString *sortType){
            StrongSelf
            [strongSelf addOrderByCondition:column sortType:sortType];
            return strongSelf;
        };
    }
    return _orderBy;
}

- (void)addOrderByCondition:(NSString *)column sortType:(NSString *)sortType
{
    if (!column.length) {
        return;
    }
    // 默认排序
    sortType = sortType.length?sortType:@"ASC";
    
    // 重复校验
    for (NSMutableDictionary *dict in self.orderByConditions) {
        if ([[dict objectForKey:@"column"] isEqualToString:column]) {
            [self.orderByConditions removeObject:dict];
            break;
        }
    }
    
    // 添加排序条件
    [self.orderByConditions addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"column" : column, @"sortType" : sortType}]];
}

- (OneStringType)limit
{
    if (_limit == nil) {
        WeakSelf
        _limit = ^(NSString *sql){
            StrongSelf
            strongSelf.limitCondition = sql;
            return strongSelf;
        };
    }
    return _limit;
}

- (FilterMapType)filtermap
{
    if (_filtermap == nil) {
        WeakSelf
        _filtermap = ^(FilterMapArgsType call){
            StrongSelf
            strongSelf.filtermapargs = call;
            return strongSelf;
        };
    }
    return _filtermap;
}

/** 连接语句 */
- (JoinType)join
{
    if (_join == nil) {
        WeakSelf
        _join = ^(NSString *tableName, NSDictionary *args){
            StrongSelf
            [strongSelf dealJoinSql:tableName args:args];
            return strongSelf;
        };
    }
    return _join;
}

- (JoinType)leftJoin
{
    if (_leftJoin == nil) {
        WeakSelf
        _leftJoin = ^(NSString *tableName, NSDictionary *args){
            StrongSelf
            [strongSelf dealJoinSql:tableName args:args];
            return strongSelf;
        };
    }
    return _leftJoin;
}

- (JoinType)rightJoin
{
    if (_rightJoin == nil) {
        WeakSelf
        _rightJoin = ^(NSString *tableName, NSDictionary *args){
            StrongSelf
            ZYLog(@"暂不支持rightJoin");
            return strongSelf;
        };
    }
    return _rightJoin;
}

- (void)dealJoinSql:(NSString *)tableName args:(NSDictionary *)args
{
    NSMutableString *sql = [NSMutableString string];
    NSArray *allKeys = args.allKeys;
    for (NSUInteger i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        [sql appendFormat:@"%@ = %@ ", key, [args objectForKey:key]];
        if (i < allKeys.count - 1) {
            [sql appendString:@"AND "];
        }
    }
    if (sql.length) {
        [self.joinConditions addObject:[NSString stringWithFormat:@"%@%@ ON %@", JoinConst, tableName, sql]];
    }
}

#pragma mark - 简化方法

- (NSArray *)getResult:(FMResultSet *)set
{
    NSMutableArray *results = [NSMutableArray array];
    
    while ([set next]) {
        NSDictionary *result = [set resultDictionary];
        
        if (self.filtermapargs) {
            id obj = self.filtermapargs(result);
            if (obj == nil) {
                continue;
            }
            [results addObject:obj];
        }else{
            [results addObject:result];
        }
    }
    return results;
}

#pragma mark - 附加操作

- (void)inTransaction:(void (^)(BOOL *))block
{
    WeakSelf
    [self.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        StrongSelf
        // 执行block操作之前 记录transactionDB 防止在执行sql时 重复放入dataBaseQueue
        strongSelf.transationDB = db;
        block?block(rollback):NULL;
        strongSelf.transationDB = nil;
    }];
}

- (void)inDatabase:(void (^)(void))block
{
    WeakSelf
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        StrongSelf
        // 执行block操作之前 记录transactionDB 防止在执行sql时 重复放入dataBaseQueue
        strongSelf.transationDB = db;
        block?block():NULL;
        strongSelf.transationDB = nil;
    }];
}

- (NSError *)inSavePoint:(void (^)(BOOL *))block
{
    WeakSelf
    return [self.databaseQueue inSavePoint:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        StrongSelf
        // 执行block操作之前 记录transactionDB 防止在执行sql时 重复放入dataBaseQueue
        strongSelf.transationDB = db;
        block?block(rollback):NULL;
        strongSelf.transationDB = nil;
    }];
}

- (void)inDeferredTransaction:(void (^)(BOOL *))block
{
    WeakSelf
    [self.databaseQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        StrongSelf
        // 执行block操作之前 记录transactionDB 防止在执行sql时 重复放入dataBaseQueue
        strongSelf.transationDB = db;
        block?block(rollback):NULL;
        strongSelf.transationDB = nil;
    }];
}

/** 重置 */
- (void)resetSql
{
    [self.whereConditions removeAllObjects];
    [self.orderByConditions removeAllObjects];
    [self.joinConditions removeAllObjects];
    [self.arguments removeAllObjects];
    self.distinctCondition = NO;
    self.havingCondition = nil;
    self.limitCondition = nil;
    self.selectCondition = nil;
    self.groupByCondition = nil;
    self.filtermapargs = nil;
}

#pragma mark - getter

- (NSMutableArray *)whereConditions
{
    if (_whereConditions == nil) {
        _whereConditions = [NSMutableArray array];
    }
    return _whereConditions;
}

- (NSMutableArray *)joinConditions
{
    if (_joinConditions == nil) {
        _joinConditions = [NSMutableArray array];
    }
    return _joinConditions;
}

- (NSMutableArray *)orderByConditions
{
    if (_orderByConditions == nil) {
        _orderByConditions = [NSMutableArray array];
    }
    return _orderByConditions;
}

- (NSMutableArray *)arguments
{
    if (_arguments == nil) {
        _arguments = [NSMutableArray array];
    }
    return _arguments;
}

@end

