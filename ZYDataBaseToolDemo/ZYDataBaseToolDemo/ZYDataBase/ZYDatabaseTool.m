//
//  ZYDataBase.m
//  DragonCup
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 BeiJingLongBei. All rights reserved.
//

#import "ZYDatabaseTool.h"
#import "FMDB.h"

@interface ZYDatabaseTool ()
@property (nonatomic, copy) NSString *tableName;
@end

@implementation ZYDatabaseTool
@synthesize table = _table;

#pragma mark - 初始化设置

+ (instancetype)sharedInstace
{
    static ZYDatabaseTool *_tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[self alloc] init];
    });
    return _tool;
}

- (void)createDatabase:(NSString *)databaseName createTableSqlFile:(NSString *)filepath
{
    
}

#pragma mark - 执行sql前先指定要操作的表格

ZYDatabaseTool * ZYTable(NSString *tableName)
{
    return [ZYDatabaseTool new].table(tableName);
}

- (OneStringType)table
{
    if (_table == nil) {
        __weak typeof(self) weakSelf = self;
        _table = ^(NSString *str){
            weakSelf.tableName = str;
            return weakSelf;
        };
    }
    return _table;
}

@end
