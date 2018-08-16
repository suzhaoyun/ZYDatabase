//
//  ZYDataBaseTool.h
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//
//  因为是里面的属性都是lazy加载的所以可读性不太好

#import <Foundation/Foundation.h>
#import "ZYDatabaseDefines.h"

@interface ZYDatabaseHandler : NSObject

/**
 Sample way of writing
 
 like: Table(@"user").select(@"name").first();
       DB.table(@"user").select(@"name").first();
 */
extern ZYDatabaseHandler * Table(NSString *table);

#pragma mark - 初始化设置

+ (instancetype)sharedInstace;

/**
 Create database if not exist.
 you must call it when app first launch because the method will get FMDBQueue instance.
 
 @params databasePath if not exist, FMDB will create database in this path
 */
- (void)createDatabaseWithPath:(NSString *)databasePath;

#pragma mark - 指定要操作的表格

/**
 Get databaseScheduler with table name,the scheduler is a static instance.
 */
@property (nonatomic, copy, readonly) OneStringType table;

#pragma mark - DDL 表格操作相关函数
/**
 表的创建会自动拼接括号
 example: DB.table(@"user").create(@"userid text not null, name text not null");
 */
@property (nonatomic, copy, readonly) DDLType create;

/**
 表的删除
 example: DB.table(@"user").drop();
 */
@property (nonatomic, copy, readonly) VoidType drop;

/**
 表结构修改
 example: DB.table(@"user").alter(@"add column id TEXT NOT NULL");
 */
@property (nonatomic, copy, readonly) DDLType alter;

#pragma mark - 执行函数，链条的结束函数，有返回结果

/**
 example insert(@{@"数据库字段" : @"插入的数据", ...})
 如果要清空某个字段 可以使用[NSNull null]
 NSNull会被翻译成sql中的null. 注意: 它和''空字符串并不相同
 */

@property (nonatomic, copy, readonly) InsertUpdateType insert;

/**
 example update(@{@"数据库字段" : @"插入的数据", ...})
 如果要清空某个字段 可以使用[NSNull null]
 NSNull会被翻译成sql中的null. 注意: 它和''空字符串并不相同
 */

@property (nonatomic, copy, readonly) InsertUpdateType update;

/**
 直接删除某条记录
 */
@property (nonatomic, copy, readonly) VoidType delete;

/**
 统计数据的条数
 */
@property (nonatomic, copy,  readonly) CountType count;

/**
 获取一条查询结果
 参数可以传nil表示获取全部字段.  也可以传入想要获取的字段
 example first(nil)  first(@"name")
 return NSDictionary  NSObject
 */

@property (nonatomic, copy, readonly) FirstType first;

/**
 获取所有的结果
 example: all()
 return NSArray<NSDictionary>
 */

@property (nonatomic, copy, readonly) MutipleType all;

#pragma mark -  条件函数

/**
 会作为搜索的条件
 参数可以是三种形式
 NSArray :
    where(@[@"name", @"=", @"zhangsan", @"sex", @">", @18])
    注意数组的个数一定是3的倍数. 不然会报错. 每一项字段的匹配都要指明匹配方式
    @">"  @"<" @"<>" @"LIKE" @"IN" @"=" ...
 NSDictionary : 
    这种传值方式的条件会默认被理解为 @"="
 NSString : 原生sql,适用于高级where条件
    这种也可以制作面向对象的APi, 但是xcode提示不太友好 就放弃了.
#waring : 所有的填写原生sql的参数, 如果是字符串类型, 记得加双引号'' , 不然可能会有问题.
        例如where(@"a = 3 OR b = 6").orWhere(@"a = 4 AND b = 7").andWhere(@"c = 3 OR a = 3")
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

/**
 用于设置别名, 筛选字段. 如果不设置默认为select *
    参数 : @[@"name as a", @"sex as mysex", @"age"]
    或者  @"name as a, sex as mysex, age"
 */

@property (nonatomic, copy, readonly) OneObjectType select;


/**
 填入原生sql
 #waring : 所有的填写原生sql的参数, 如果是字符串类型, 记得加双引号'' , 不然可能会有问题.
 having可以对分组数据进行条件筛选 where不能
 */

@property (nonatomic, copy, readonly) OneStringType having;

#pragma mark -  附加操作

/**
 连接查询
 第一个参数为要连接的表名
 第二个参数为连接条件 NSDictionary:
 #warning : 只能填写连接条件. 不可以填写条件判断. 如果要判断请单独使用where语句
    join(@"b", @{@"b.name" : @"a.name"})
 */

@property (nonatomic, copy, readonly) JoinType join;

/**
 左连接 参数和join完全一致
 */

@property (nonatomic, copy, readonly) JoinType leftJoin;

/**
 右连接 参数和join完全一致 (Sqlite暂不支持)
 */

@property (nonatomic, copy, readonly) JoinType rightJoin;

/**
 分组操作
 参数很简单: 哪个字段作为分组标志
 example : @"name"
    也可以设置为多参数
    @"name, age" : 表示为先按name分组 , 再按age分组
 */

@property (nonatomic, copy, readonly) OneStringType groupBy;

/**
 排序操作
 参数为(a, b)
 orderBy(@"name", @"ASC")
 所以参数必须成对出现,第二个参数可以指定排序类型
 可以使用多次orderBy 已保证先后顺序  orderBy(@"a", @"ASC").orderBy(@"b", @"DESC")
 这样会先已a排序,再已b字段排序  如果设置两次a, 会以最后一次的排序方式和未知为准!
 */

@property (nonatomic, copy, readonly) OrderByType orderBy;

#pragma mark - 过滤函数
/**
 限制查询出来的条数
 可以设置查询条数, 也可以自定义起始位置
 example : limit(@"2")   limit(@"2, 2");
 */

@property (nonatomic, copy, readonly) OneStringType limit;

/**
 可以对查询出的数据进行过滤或自定义
 return nil则认为该数据被过滤
 */
@property (nonatomic, copy, readonly) FilterMapType filtermap;

/**
 获取所有的结果 (去除重复数据)
 distinct作用 : 跟在select后面, select 后面的字段会被指定为判断重复的依据
 example: SELECT DISTINCT a, b FROM xx; 会把a和b两列的值作为是否重复的判断标准
 这个api使用时可以放在任意位置
 */

@property (nonatomic, copy, readonly) DistinctType distinct;

#pragma mark - 事务、并发相关函数 调用FMDB的api

/** Synchronously perform database operations on queue.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDatabase:(void (^)(void))block;

/** Synchronously perform database operations on queue, using transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inTransaction:(void (^)(BOOL *rollback))block;

/** Synchronously perform database operations on queue, using deferred transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDeferredTransaction:(void (^)(BOOL *rollback))block;

///-----------------------------------------------
/// @name Dispatching database operations to queue
///-----------------------------------------------

/** Synchronously perform database operations using save point.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

// NOTE: you can not nest these, since calling it will pull another database out of the pool and you'll get a deadlock.
// If you need to nest, use FMDatabase's startSavePointWithName:error: instead.
- (NSError * _Nullable)inSavePoint:(void (^)(BOOL *rollback))block;

@end

