# 中文介绍
你还在写生硬的SQL语句吗？移动端开发的小白不太懂数据库怎么办？ZYDatabase是一种全新的操作数据库的方式,采用了将SQL语句拆分而用采用链式编程的方式内部拼接SQL, 即增加了可读性，简化了代码，又不脱离SQL语法本质。
## 简单演示
```objc
// 原来我们使用FMDB的代码
FMResultSet *resultSet = [database executeQuery:@"select * from record where userid = ?", @"123"];
NSMutableArray *array = [NSMutableArray array];
if ([resultSet next]) {
    NSDictionary *dict = [resultSet resultDictionary];
    [array addObject:dict];
}

// 使用ZYDatabase
DB.table(@"record").where(@{@"userid" : @"123"}).all();
```
大家可以看到，同样是一个条件查询，FMDB不仅需要写生涩的sql语句，而且还需要多行代码来遍历取值，而ZYDatabase一行代码就可以搞定同样的事情，并且具备更高的可读性.
## 使用方法
1. ZYDatabase是对FMDB的封装，所以项目中必须添加FMDB，当前版本是对可行性的一个验证，后续为了性能可能会移除对FMDB的依赖。
2. 下载工程后直接将ZYDatabase文件夹拖入项目即可。
3. 在需要使用ZYDatabase的地方导入头文件即可
```objc
#import "ZYDatabase.h"
```
## 简单介绍
### 1.数据库的创建
ZYDatabaseHandler是ZYDatabase的核心类，所有的业务都是这个核心类完成的。[ZYDatabaseHandler shareInstance]即可获取到这个核心类的实现。
```objc
// 创建数据库
NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"demo.sqlite"];
[DB createDatabaseWithPath:path];
```
数据库的大多数操作都是以table为基础的，所以任何操作的第一步都是先指定要操作的表。handler中即可指定table.
```objc
[ZYDatabaseHandler shareInstance].table(@"student")
```
为了简化书写，ZYDatabase提供了两种更简单的获取table的方式
1. 使用宏定义 #define DB [ZYDatabaseHandler sharedInstace]  所以这样即可获取table, 
```objc
DB.table(@"student");
```
2. 使用C函数也可以直接获取table
```objc
Table(@"student");
```
### 2.DDL 表的操作相关 
```objc
// 创建一个student表
BOOL success = DB.table(@"student").create(@"name text not null, age int default = 0, schoolid varchar(100)");

// 删除student表
BOOL success = DB.table(@"student").drop();

// 修改表
BOOL success = DB.table(@"student").alter(@"add column test text");
```
### 3.DQL 查询语句
```objc
// 单条查询
DB.table(@"student").where(@{@"age" : @0}).first();

// 多条查询
DB.table(@"student").where(@{@"age" : @0}).all();

// 复杂条件 where支持三种参数 具体可查看api说明
DB.table(@"student").where(@[@"name", @"like", @"%芳%"]).orWhere(@{@"age" : @18}).andWhere(@{@"schoolid":@1}).all();

// 排序
DB.table(@"student").orderBy(@"age", @"DESC").all();

// 统计数目
DB.table(@"student").count();

// 分组
DB.table(@"student").select(@"age, count(*) as c").groupBy(@"age").having(@"c = 2").all();

// limit语句
DB.table(@"student").limit(@"0, 2").all();

// 多表关联...
DB.table(@"student as stu").join(@"school as sch", @{@"stu.schoolid":@"sch.schoolid"}).all();

// 自定义数据过滤
DB.table(@"student").where(@{@"age" : @0}).filtermap(^id(NSDictionary *dict) {
    // 例如可以在这里进行字典转模型

    // 也可以把数据过滤掉 return nil即可

    return dict;
}).all();
```
### 4.DML 增删改 
```objc
// 插入新数据
DB.table(@"student").insert(@{@"name" : @"张三", @"age" : @22, @"schoolid" : @1});

// 删除
DB.table(@"student").where(@"name = '张三'").delete();
DB.table(@"student").where(@[@"name", @"like", @"%张三%"]).delete();
DB.table(@"student").where(@{@"name" : @"张三"}).delete();

// 更新
DB.where(@{@"name" : @"张三"}).update(@{@"name" : @"李四"});
```
## 补充
另外ZYDatabase中还保留了FMDB多线程操作，事务的操作。下图是ZYDatabase开发时的思维导图

![Alt text](http://upload-images.jianshu.io/upload_images/1941597-2f3c6115b55fd5ae.png?imageMogr2/auto-orient/strip)
一直内部使用，可能潜在很多问题，希望大家多多issues。
