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

#import "ZYDatabaseTool.h"
#import "ZYDatabaseResult.h"
#import "FMDB.h"

#endif /* ZYDatabase_h */
