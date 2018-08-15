# 中文介绍
你还在写生硬sql语句吗？ZYDatabase是一种全新的操作数据库方式,用链式编程的方式数写sql, 增加可读性，简化代码，给你不一样的体验。
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
## API介绍
### DDL 表的操作相关 

### DQL 

### DML 

## 补充


![Alt text](http://upload-images.jianshu.io/upload_images/1941597-2f3c6115b55fd5ae.png?imageMogr2/auto-orient/strip)
