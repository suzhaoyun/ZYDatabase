//
//  NSObject+ZYDatabaseModel.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZYDatabaseTool;

@protocol ZYDatabaseModel <NSObject>

+ (NSString *)tableName;

+ (NSString *)primaryKey;

@optional

+ (NSDictionary *)fillTable;

@end

@interface NSObject (ZYDatabaseModel)<ZYDatabaseModel>

@property (class, readonly) ZYDatabaseTool *table;

/**
 如果没有就插入 如果有就编辑
 */
- (void)save;

- (void)delete;

@end
