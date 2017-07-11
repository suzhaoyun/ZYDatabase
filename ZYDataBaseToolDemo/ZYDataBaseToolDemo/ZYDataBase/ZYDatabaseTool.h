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
typedef ZYDatabaseTool  * (^OneDictType)(NSDictionary *args);
typedef ZYDatabaseTool  * (^OneArrayType)(NSArray *args);
typedef ZYDatabaseTool  * (^OneObjectType)(id args);
typedef ZYDatabaseTool  * (^JoinType)(NSString *tableName, NSDictionary *onConditions);
typedef ZYDatabaseTool  * (^OrderByType)(NSString *column, NSString *sortType);

typedef BOOL (^DeleteType)();
typedef BOOL (^InsertUpdateType)(NSDictionary *args);
typedef NSDictionary * (^FirstType)();
typedef id (^MutaipleMapArgsType)(NSDictionary *dict);
typedef ZYDatabaseResult * (^FirstMapType)(NSString *column);
typedef ZYDatabaseTool * (^DistinctType)();
typedef NSArray<NSDictionary *> * (^MutipleType)();
typedef NSArray * (^MutaipleMapType)(MutaipleMapArgsType type);
typedef NSInteger (^CountType)();

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

@property (nonatomic, copy, readonly) DeleteType delete;

/**
 获取一条查询结果
 参数可以传nil表示获取全部字段.  也可以传入想要获取的字段
 example first(nil)  first(@"name")
 return NSDictionary  NSObject
 */

@property (nonatomic, copy, readonly) FirstType first;

/**
 快速获取指定列的值
 return: ZYDatabaseResult 这个类可以用来快速获取指定类型的值
 example : first_map(@"name").stringValue
 first_map(@"isfriend").boolValue
 */
@property (nonatomic, copy, readonly) FirstMapType first_;

/**
 获取所有的结果
 example: all()
 return NSArray<NSDictionary>
 */

@property (nonatomic, copy, readonly) MutipleType all;

/**
 过滤函数. 可以对每一列的结果进行自定义, 最终返回一个数组里
 example : NSArray *rs = DB.table(@"User").all_map(^id(NSDictionary *obj) {
                return [obj objectForKey:@"name"];
           });
    这样可以在rs数组中得到的都是name了
    最常用的操作 : 可以用来字典转模型
 */
@property (nonatomic, copy, readonly) MutaipleMapType all_;

/**
 获取所有的结果 (去除重复数据)
 distinct作用 : 跟在select后面, select 后面的字段会被指定为判断重复的依据
 example: SELECT DISTINCT a, b FROM xx; 会把a和b两列的值作为是否重复的判断标准
 这个api使用时可以放在任意位置
 */

@property (nonatomic, copy, readonly) DistinctType distinct;

/**
 统计数据的条数
 */
@property (nonatomic, copy,  readonly) CountType count;

#pragma mark -  条件函数

/**
 会作为搜索的条件
 参数可以是两种形式
 NSArray :
    where(@[@"name", @"=", @"zhangsan", @"sex", @">", @18])
    注意数组的个数一定是3的倍数. 不然会报错. 每一项字段的匹配都要指明匹配方式
    @">"  @"<" @"<>" @"LIKE" @"IN" @"=" ...
 NSDictionary : 
    这种传值方式会默认被理解为 @"="
 NSString : 原生sql,适用于高级where条件
    这种也可以制作面向对象的APi, 但是提示不太友好 就放弃了.
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

/**
 限制查询出来的条数
 可以设置查询条数, 也可以自定义起始位置
 example : limit(@"2")   limit(@"2, 2");
 */

@property (nonatomic, copy, readonly) OneStringType limit;

#pragma mark - 供给开发者用于特殊操作

/**
 FMDB的操作类
 [DB.databaseQueue inTransaction:^{
    DB.table() xx 这种写法是错误的. 请使用下面的方法代替
 }];
 
 [DB inTransaction:^{
    DB.table().delete();
 }];
 */

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

/**
 开启一个事务.
 */

- (void)inTransaction:(__attribute__((noescape)) void (^)(BOOL *rollback))block;

@end

