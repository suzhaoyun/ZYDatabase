//
//  ZYDatabase.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 ZYSu. All rights reserved.
//  

#ifndef ZYDatabase_h
#define ZYDatabase_h

/**
 快捷调用工具类
 */
#ifndef DB
#define DB [ZYDatabaseTool sharedInstace]
#endif

/**
 数据库的名字
 */
#define ZYDatabaseSqliteName @"ZYDatabaseSqliteDemo.sqlite"

/**
 初始的建表语句 (初始的创建表格语句 必须放在这个文件中)
 */
#define ZYDatabaseTableSqlFileName @"ZYDatabaseTableSqlFileName.sql"

#import "ZYDatabaseTool.h"
#import "ZYDatabaseResult.h"
#import "FMDB.h"

#endif /* ZYDatabase_h */
