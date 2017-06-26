//
//  NSObject+ZYDatabaseModel.m
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/26.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYDatabaseModel.h"
#import "ZYDatabaseTool.h"

@implementation NSObject (ZYDatabaseModel)

+ (ZYDatabaseTool *)table
{
    return [ZYDatabaseTool sharedInstace].table([self tableName]);
}

- (void)save
{
    
}

- (void)insert
{
    
}

- (void)delete
{
    
}

+ (NSString *)tableName{return nil;};
+ (NSString *)primaryKey{return nil;}
@end
