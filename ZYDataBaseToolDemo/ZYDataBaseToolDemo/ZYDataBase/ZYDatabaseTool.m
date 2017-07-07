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
#import "ZYDatabaseResult.h"

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
@property (nonatomic, strong) NSMutableArray *havingConditions;
@property (nonatomic, strong) NSMutableArray *onConditions;
@property (nonatomic, strong) ZYDatabaseResult *result;
@property (nonatomic, copy) NSString *limitCondition;
@property (nonatomic, strong) id selectCondition;
@property (nonatomic, strong) NSMutableArray *orderByConditions;
@property (nonatomic, copy) NSString *groupByCondition;
@end

@implementation ZYDatabaseTool
// 为了懒加载, 只能重写get方法. 但是只读属性如果实现了get方法,就不会自动生成_下划线变量了.需要手动合成
@synthesize table = _table;
@synthesize insert = _insert;
@synthesize update = _update;
@synthesize delete = _delete;
@synthesize where = _where;
@synthesize andWhere = _andWhere;
@synthesize orWhere = _orWhere;
@synthesize first = _first;
@synthesize first_map = _first_map;
@synthesize all = _all;
@synthesize all_map = _all_map;
@synthesize limit = _limit;
@synthesize select = _select;
@synthesize orderBy = _orderBy;
@synthesize groupBy = _groupBy;
@synthesize having = _having;
@synthesize orHaving = _orHaving;
@synthesize andHaving = _andHaving;
@synthesize leftJoin = _leftJoin;
@synthesize join = _join;
@synthesize rightJoin = _rightJoin;

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
            [strongSelf resetSql];
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
        if ([obj isKindOfClass:[NSNull class]]) {
            [values addObject:@"null"];
        }else{
            [values addObject:[NSString stringWithFormat:@"'%@'", obj]];
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
        if ([obj isKindOfClass:[NSNull class]]) {
            [sql appendFormat:@"%@ = null", key];
        }else{
            [sql appendFormat:@"%@ = '%@'", key, obj];
        }
        if (i < keys.count - 1) {
            [sql appendString:@", "];
        }else{
            [sql appendString:@" "];
        }
    }
    
    // 添加筛选条件
    [sql appendFormat:@"%@;", [self getConditionSql:self.whereConditions]];
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
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@%@", DeleteConst, self.tableName];
    NSString *whereSql = [self getConditionSql:self.whereConditions];
    if (whereSql.length) {
        [sql appendFormat:@" %@", whereSql];
    }
    [sql appendString:@";"];
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
- (OneObjectType)having
{
    if (_having == nil) {
        WeakSelf
        _having = ^(id args){
            StrongSelf
            if (args){
                [strongSelf.havingConditions addObject:@{@"Type" : @"AND", @"Content" : args}];
            }
            return strongSelf;
        };
    }
    return _having;
}

- (OneObjectType)andHaving
{
    if (_andHaving == nil) {
        WeakSelf
        _andHaving = ^(id args){
            StrongSelf
            if (args){
                [strongSelf.havingConditions addObject:@{@"Type" : @"AND", @"Content" : args}];
            }
            return strongSelf;
        };
    }
    return _andHaving;
}

- (OneObjectType)orHaving
{
    if (_orHaving == nil) {
        WeakSelf
        _orHaving = ^(id args){
            StrongSelf
            if (args){
                [strongSelf.havingConditions addObject:@{@"Type" : @"OR", @"Content" : args}];
            }
            return strongSelf;
        };
    }
    return _orHaving;
}

- (NSString *)getConditionSql:(NSMutableArray *)conditions
{
    NSMutableString *sql = [NSMutableString string];
    if (conditions.count == 0) {
        return sql;
    }
    
    // 纠正条件顺序  防止第一个语句有多个条件但第一个条件是OR
    [conditions sortUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull obj1, NSDictionary *  _Nonnull obj2) {
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
    
    NSString *condition = nil;
    if (conditions == self.whereConditions) {
        condition = WhereConst;
    }
    else if (conditions == self.havingConditions){
        condition = HavingConst;
    }
    else if (conditions == self.onConditions){
        condition = ONConst;
    }
    
    if (!condition) {
        return @"";
    }
    
    [sql appendString:condition];
    
    for (NSUInteger  i = 0; i < conditions.count; i++) {
        NSDictionary *whereArgs = conditions[i];
        NSString *type = [whereArgs objectForKey:@"Type"];
        
        id args = [whereArgs objectForKey:@"Content"];
        
        NSMutableString *contentSql = [NSMutableString string];
        
        if ([args isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = args;
            NSArray *allkeys = dict.allKeys;
            for (NSUInteger i = 0; i < allkeys.count; i++) {
                NSString *key = allkeys[i];
                id obj = [dict objectForKey:key];
                if ([obj isKindOfClass:[NSNull class]]) {
                    [contentSql appendFormat:@"%@ = null", key];
                }else{
                    [contentSql appendFormat:@"%@ = '%@'", key, obj];
                }
                if (i < allkeys.count - 1) {
                    [contentSql appendString:@" AND "];
                }
            }
        }
        else if ([args isKindOfClass:[NSArray class]]) {
            NSArray *arr = args;
            NSAssert(arr.count % 3 == 0, @"%@%@参数有问题,参数个数必须是3的倍数", arr, condition);
            if (arr.count == 0) {
                continue;
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
                else{
                    if ([obj isKindOfClass:[NSNull class]]) {
                        [contentSql appendString:@"null"];
                    }else{
                        [contentSql appendFormat:@"'%@'", obj];
                    }
                    
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
    
    return [sql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

- (FirstMapType)first_map
{
    if (_first_map == nil) {
        WeakSelf
        _first_map = ^(NSString *column){
            StrongSelf
            [strongSelf.result setDict:strongSelf.first() key:column];
            return strongSelf.result;
        };
    }
    return _first_map;
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
                set = [strongSelf.transationDB executeQuery:[strongSelf getQuerySql]];
                [results addObjectsFromArray:[strongSelf getResult:set filter:nil]];

            }else{
                [strongSelf.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    set = [db executeQuery:[strongSelf getQuerySql]];
                    [results addObjectsFromArray:[strongSelf getResult:set filter:nil]];
                }];
            }
            return results;
        };
    }
    return _all;
}

- (MutaipleMapType)all_map
{
    if (_all_map == nil) {
        WeakSelf
        _all_map = ^(MutaipleMapArgsType type){
            StrongSelf
            NSMutableArray *results = [NSMutableArray array];
            __block FMResultSet *set = nil;
            if (strongSelf.transationDB) {
                set = [strongSelf.transationDB executeQuery:[strongSelf getQuerySql]];
                [results addObjectsFromArray:[strongSelf getResult:set filter:type]];
                
            }else{
                [strongSelf.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    set = [db executeQuery:[strongSelf getQuerySql]];
                    [results addObjectsFromArray:[strongSelf getResult:set filter:type]];
                }];
            }
            return results;
        };
    }
    return _all_map;
}

- (NSString *)getQuerySql
{
    NSAssert(self.tableName.length > 0, @"请先指定要操作的表...");
    
    NSMutableString *sql = [NSMutableString stringWithString:SelectConst];
    
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
    
    // 拼接where条件
    NSString *whereSql = [self getConditionSql:self.whereConditions];
    if (whereSql.length) {
        [sql appendFormat:@"%@ ", whereSql];
    }
    
    // 拼接group by 语句 having字句
    if (self.groupByCondition.length) {
        [sql appendFormat:@"%@%@ ", GroupByConst, self.groupByCondition];
        
        if (self.havingConditions.count) {
            [sql appendFormat:@"%@ ", [self getConditionSql:self.havingConditions]];
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

#pragma mark - 简化方法

- (NSArray *)getResult:(FMResultSet *)set filter:(MutaipleMapArgsType)type
{
    NSMutableArray *results = [NSMutableArray array];
    while ([set next]) {
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
        
        if (type) {
            id obj = type(result);
            NSAssert(obj != nil, @"all_map的结果值不能是nil");
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
    [self.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        self.transationDB = db;
        block?block(rollback):NULL;
        self.transationDB = nil;
    }];
}

#pragma mark - 公共操作
/** 重置sql */
- (void)resetSql
{
    [self.whereConditions removeAllObjects];
    [self.orderByConditions removeAllObjects];
    [self.havingConditions removeAllObjects];
    [self.onConditions removeAllObjects];
    self.limitCondition = nil;
    self.selectCondition = nil;
    self.groupByCondition = nil;
}

#pragma mark - getter

- (NSMutableArray *)whereConditions
{
    if (_whereConditions == nil) {
        _whereConditions = [NSMutableArray array];
    }
    return _whereConditions;
}

- (NSMutableArray *)havingConditions
{
    if (_havingConditions == nil) {
        _havingConditions = [NSMutableArray array];
    }
    return _havingConditions;
}

- (NSMutableArray *)onConditions
{
    if (_onConditions == nil) {
        _onConditions = [NSMutableArray array];
    }
    return _onConditions;
}

- (ZYDatabaseResult *)result
{
    if (_result == nil) {
        _result = [[ZYDatabaseResult alloc] init];
    }
    return _result;
}

- (NSMutableArray *)orderByConditions
{
    if (_orderByConditions == nil) {
        _orderByConditions = [NSMutableArray array];
    }
    return _orderByConditions;
}

@end

