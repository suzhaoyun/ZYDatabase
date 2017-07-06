//
//  DB.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/7/6.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DB : NSObject

/**
 初始化数据库 创建表格
 
 @param databaseName 数据库名称
 @param filepath sql文件路径
 #warning : 客户端每次启动都会执行sql 所以创表语句中一定要添加IF NOT EXISTS
 */

+ (void)createDatabase:(NSString *)databaseName createTableSqlFilePath:(NSString *)filepath;

/**
 FMDB的操作类
 */

@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

@end
