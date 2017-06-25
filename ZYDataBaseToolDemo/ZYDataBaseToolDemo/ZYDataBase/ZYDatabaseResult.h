//
//  ZYDatabaseResult.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 ZYSu. All rights reserved.
//  执行结果值

#import <Foundation/Foundation.h>
typedef id (^ModelType)(Class className);
@interface ZYDatabaseResult : NSObject

+ (instancetype)databaseResult:(id)obj;

@property (nonatomic, readonly) NSArray *arrayValue;
@property (nonatomic, readonly) NSString *stringValue;
@property (nonatomic, readonly) NSInteger integerValue;
@property (nonatomic, copy, readonly) ModelType modelValue;
@property (nonatomic, readonly) NSDictionary *dictValue;
@property (nonatomic, readonly) id objValue;
@property (nonatomic, readonly) int intValue;
@property (nonatomic, readonly) BOOL booleanValue;
@property (nonatomic, readonly) long longValue;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly) long long longlongValue;

@end
