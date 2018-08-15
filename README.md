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
### 数据库的创建
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
### DDL 表的操作相关 
```objc
// 创建一个student表
BOOL success = DB.table(@"student").create(@"name text not null, age int default = 0, schoolid varchar(100)");

// 删除student表
BOOL success = DB.table(@"student").drop();

// 修改表
BOOL success = DB.table(@"student").alter(@"add column test text");
```
### DQL 

### DML 

## 补充


![Alt text](http://upload-images.jianshu.io/upload_images/1941597-2f3c6115b55fd5ae.png?imageMogr2/auto-orient/strip)
