//
//  ZYDataBaseTool.h
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//  仿Laravel框架做的一个面向对象的sql语句api (暂时只支持单数据库)
//  内部使用FMDatabaseQueue实现, 是保证线程安全的

#import <Foundation/Foundation.h>

@class ZYDatabaseTool, FMDatabaseQueue, ZYDatabaseResult;

typedef ZYDatabaseTool  * (^OneStringType)(NSString *args);
typedef ZYDatabaseTool  * (^OneObjectType)(id args);
typedef ZYDatabaseTool  * (^OneDictType)(NSDictionary *args);
typedef ZYDatabaseTool  * (^OneArrayType)(NSArray *args);
typedef ZYDatabaseTool  * (^JoinType)(NSString *tableName, id args);
typedef ZYDatabaseTool  * (^OrderByType)(NSString *column, NSString *sortType);

typedef BOOL (^DeleteType)();
typedef BOOL (^InsertUpdateType)(NSDictionary *args);
typedef NSDictionary * (^FirstType)();
typedef ZYDatabaseResult * (^FirstMapType)(NSString *column);
typedef NSArray<NSDictionary *> * (^MutipleType)();
typedef NSArray * (^MutaipleMapType)(id (^)(NSDictionary *dict));

@interface ZYDatabaseTool : NSObject

#pragma mark - 初始化设置

/**
 单例 
    在程序启动时 或者类加载时可以去初始化数据库
 */

+ (instancetype)sharedInstace;

/**
 初始化数据库 创建表格

 @param databaseName 数据库名称
 @param filepath sql文件路径
 #warning : 客户端每次启动都会执行sql 所以创表语句中一定要添加IF NOT EXISTS
 */

- (void)createDatabase:(NSString *)databaseName createTableSqlFilePath:(NSString *)filepath;

#pragma mark - 执行sql前先指定要操作的表格

/**
 指定操作的表格!!! 最好先制定要操作的表格再进行增删改查操作
    [ZYDadabaseTool sharedInstance].table(@"user")
 */

@property (nonatomic, copy, readonly) OneStringType table;

#pragma mark - 执行函数(直接执行, 返回ZYDatabaseResult)

/**
 example insert(@{@"数据库字段" : @"插入的数据", ...})
 如果要清空某个字段 可以使用[NSNull null] 或者@""
 */

@property (nonatomic, copy, readonly) InsertUpdateType insert;

/**
 example update(@{@"数据库字段" : @"插入的数据", ...})
 如果要清空某个字段 可以使用[NSNull null] 或者@""
 */

@property (nonatomic, copy, readonly) InsertUpdateType update;

/**
 直接删除某条记录
 */

@property (nonatomic, copy, readonly) DeleteType delete;

/**
 获取一条查询结果
 参数可以传nil表示获取全部字段.  也可以传入想要获取的字段
 example first(nil)  first(@"name")
 return NSDictionary  NSObject
 */

@property (nonatomic, copy, readonly) FirstType first;


/**
 过滤函数  可以直接指定列名 来获取指定列的值
    return: ZYDatabaseResult 这个类可以用来快速获取指定类型的值
    example : first_map(@"name").stringValue 
              first_map(@"isfriend").boolValue
 */
@property (nonatomic, copy, readonly) FirstMapType first_map;

/**
 获取所有的结果
 example: all()
 return NSArray<NSDictionary>
 */

@property (nonatomic, copy, readonly) MutipleType all;

/**
 过滤函数. 可以对每一列的结果进行自定义, 最终返回一个数组里
 example : NSArray *rs = ZYTable(@"User").all_map(^id(NSDictionary *obj) {
                return [obj objectForKey:@"name"];
           });
    这样可以在rs数组中得到的都是name了
    最常用的操作 : 可以用来字典转模型
 */
@property (nonatomic, copy, readonly) MutaipleMapType all_map;

/**
 获取所有的结果 (去除重复数据)
 distinct用法 : 跟在select后面, select 后面的字段会被指定为判断重复的依据
 example: select distinct a, b from xx; 会把a和b两列的值作为是否重复的判断标准
 return NSArray<NSDictionary>
 */

@property (nonatomic, copy, readonly) MutipleType distinct;

/**
 同all_map用法保持一致
 */
@property (nonatomic, copy, readonly) MutaipleMapType distinct_map;

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
 NSString : 自由的定义sql语句
    这种也可以制作面向对象的APi, 但是提示不太友好 就放弃了.
    适用于聚合条件
        例如where(@"a = 3 OR b = 6").orWhere(@"a = 4 AND b = 7").andWhere(@"c = 3 OR a = 3")
 */

@property (nonatomic, copy, readonly) OneObjectType where;

/**
 和where完全一致, 只是为了多where条件时增加可读性
 */

@property (nonatomic, copy, readonly) OneObjectType andWhere;
/**
 用于设置别名, 筛选字段. 如果不设置默认为select *
    参数 : @[@"name as a", @"sex as mysex", @"age"]
    或者  @"name as a, sex as mysex, age"
 */

@property (nonatomic, copy, readonly) OneObjectType select;

/**
 参数和where完全一致
    会在条件前添加 'OR'
 */

@property (nonatomic, copy, readonly) OneObjectType orWhere;
/**
 参数和where一致  
    having可以对分组数据进行条件筛选 where不能
 */

@property (nonatomic, copy, readonly) OneObjectType having;

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
 参数很简单: 哪个字段作为分组标志
 */

@property (nonatomic, copy, readonly) OneStringType groupBy;

/**
 排序操作
 参数为(a, b)
 orderBy(@"name", @"ASC")
 所以参数必须成对出现,第二个参数可以指定排序类型
 可以使用多次orderBy 已保证先后顺序  orderBy(@"a", @"ASC").orderBy(@"b", @"DESC")
 这样会先已a排序,再已b字段排序  如果设置两次a, 会以最后一次的排序方式为准!
 */

@property (nonatomic, copy, readonly) OrderByType orderBy;

/**
 限制查询出来的条数
 可以设置查询条数, 也可以自定义起始位置
 example : limit(@"2")   limit(@"2, 2");
 */

@property (nonatomic, copy, readonly) OneStringType limit;

#pragma mark - 供给开发者用于特殊操作

/**
 FMDB的操作类
 */

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

/**
 开启一个事务
 */

- (void)inTransaction:(__attribute__((noescape)) void (^)(BOOL *rollback))block;

@end

