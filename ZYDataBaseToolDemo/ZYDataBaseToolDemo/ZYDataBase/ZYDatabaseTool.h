//
//  ZYDataBaseTool.h
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//  仿laravel做的一个面向对象的链式数据库操作工具 暂时只支持单数据库

#import <Foundation/Foundation.h>

@class ZYDatabaseTool, FMDatabase, ZYDatabaseResult;

typedef ZYDatabaseTool * (^OneStringType)(NSString *args);
typedef ZYDatabaseTool * (^OneObjectType)(id args);
typedef ZYDatabaseTool * (^OneDictType)(NSDictionary *args);
typedef ZYDatabaseTool * (^OneArrayType)(NSArray *args);
typedef ZYDatabaseTool * (^JoinType)(NSString *tableName, id args);
typedef ZYDatabaseResult * (^ExecuteType)();
typedef ZYDatabaseResult * (^ExecuteDictType)(NSDictionary *args);
typedef ZYDatabaseResult * (^ExecuteStringType)(NSString *args);

@interface ZYDatabaseTool : NSObject

#pragma mark - 初始化设置

/**
 单例
 */
+ (instancetype)sharedInstace;

/**
 初始化数据库 创建表格

 @param databaseName 数据库名称
 @param filepath sql文件路径
 */
- (void)createDatabase:(NSString *)databaseName createTableSqlFile:(NSString *)filepath;

#pragma mark - 执行sql前先指定要操作的表格

/**
 便捷函数 等价与 [ZYDatabaseTool sharedInstace].table(@"tableName")

 @param tableName 表格名
 @return ZYDatabaseTool
 */
ZYDatabaseTool * ZYTable(NSString *tableName);

/**
 指定操作的表格!!! 最好先制定要操作的表格再进行增删改查操作
    DB.table(@"user")
 */
@property (nonatomic, copy, readonly) OneStringType table;

#pragma mark - 执行函数(直接执行, 返回ZYDatabaseResult)

/**
 example insert(@{@"数据库字段" : @"插入的数据", ...})
 如果要清空某个字段 可以使用[NSNull null] 或者@""
 */
@property (nonatomic, copy, readonly) ExecuteDictType insert;

/**
 example update(@{@"数据库字段" : @"插入的数据", ...})
 */
@property (nonatomic, copy, readonly) ExecuteDictType update;

/**
 直接删除某条记录
 */
@property (nonatomic, copy, readonly) ExecuteType delete;

/**
 获取一条查询结果
 参数可以传nil表示获取全部字段.  也可以传入想要获取的字段
 example first(nil)  first(@"name")
 */
@property (nonatomic, copy, readonly) ExecuteStringType first;

/**
 获取所有的结果
 参数可以传nil表示获取全部字段.  也可以传入想要获取的字段
 example get(nil)  get(@"name")
 */
@property (nonatomic, copy, readonly) ExecuteStringType get;

#pragma mark -  条件函数
/**
 会作为搜索的条件
 参数可以是两种形式
 NSArray :
    where(@[@"name", @"=", @"zhangsan", @"sex", @">", @18])
    注意数组的个数一定是3的倍数. 不然会报错. 每一项字段的匹配都要指明匹配方式
    @">"  @"<" @"LIKE" @"IN" @"=" ...
 NSDictionary : 
    这种传值方式会默认被理解为 @"="
 */
@property (nonatomic, copy, readonly) OneObjectType where;

/**
 和where完全一致, 只是为了多where条件时增加可读性
 */
@property (nonatomic, copy, readonly) OneObjectType andWhere;

/**
 参数和where完全一致
    会在条件前添加 'OR'
 */
@property (nonatomic, copy, readonly) OneObjectType orWhere;

#pragma mark -  附加操作

/**
 连接查询
 第一个参数为要连接的表名
    join(@"b", nil)
 第二个参数为连接条件,参数也可以是两种类型
 NSArray:  必须制定符号 不然崩溃
    join(@"b", @[@"b.name", @"=", @"a.name"])
    小tip 可以不指定表名, 默认前面为要连接的表的字段
 NSDictionary:
    join(@"b", @{@"name" : @"name"}) 默认为'='号条件
 */
@property (nonatomic, copy, readonly) JoinType join;

/**
 左连接 参数和join完全一致
 */
@property (nonatomic, copy, readonly) JoinType leftJoin;

/**
 右连接 参数和join完全一致
 */
@property (nonatomic, copy, readonly) JoinType rightJoin;

/**
 分组操作
 参数很简单 以哪个字段作为分组标志
 */
@property (nonatomic, copy, readonly) OneStringType groupBy;

/**
 排序操作
 参数为array
 orderBy(@[@"name", @"ASC", @"sex", @"DESC"])
 所以参数必须为2的倍数 必须制定排序类型
 */
@property (nonatomic, copy, readonly) OneArrayType orderBy;

#pragma mark - 供给开发者用于特殊操作
/**
 FMDB的操作类
 */
@property (nonatomic, readonly) FMDatabase *db;

/**
 开启一个事务

 @return return value description
 */
- (BOOL)beginTransaction;

/**
 提交事务

 @return return value description
 */
- (BOOL)commit;

/**
 如果发生错误, 可以调用此函数回滚之前执行的sql

 @return return value description
 */
- (BOOL)rollback;

@end

