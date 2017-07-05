//
//  ZYDatabaseResult.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/7/5.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYDatabaseResult : NSObject

+ (instancetype)databaseResult:(NSDictionary *)dict key:(NSString *)key;

@property (nonatomic, copy, readonly) NSString *stringValue;
@property (nonatomic, strong, readonly) NSDictionary *dictValue;
@property (nonatomic, strong, readonly) NSArray *arrayValue;
@property (nonatomic, assign, readonly) float floatValue;
@property (nonatomic, assign, readonly) double doubleValue;
@property (nonatomic, assign, readonly) long longValue;
@property (nonatomic, assign, readonly) BOOL boolValue;
@property (nonatomic, assign, readonly) NSInteger integerValue;
@property (nonatomic, strong, readonly) NSData *dataValue;

@end
