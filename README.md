# 中文介绍
你还在写生硬sql语句吗？ZYDatabase是一种全新的操作数据库方式,用链式编程的方式数写sql, 增加可读性，简化代码，给你不一样的体验。
##简单演示
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
大家可以看到，同样是一个条件查询，FMDB不仅需要写生涩的sql语句，而且还需要多行代码来遍历取值，而ZYDatabase一行代码就可以搞定同样的事情，并且具备更高的可读性

![Alt text](http://upload-images.jianshu.io/upload_images/1941597-2f3c6115b55fd5ae.png?imageMogr2/auto-orient/strip)
