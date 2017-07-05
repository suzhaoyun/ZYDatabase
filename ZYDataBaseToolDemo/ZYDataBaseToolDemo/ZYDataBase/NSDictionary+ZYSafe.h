//
//  NSDictionary+ZY
//  ZY
//
//  Created by ZY on 15/6/8.
//  Copyright (c) 2015年 苏兆云. All rights reserved.
//  安全的字典取值

#import <Foundation/Foundation.h>

// 是不是安全的字典
#define IsSafeDict(dict) (BOOL)([dict isKindOfClass:[NSDictionary class]])

@interface NSDictionary (ZYSafe)

- (NSString *)stringForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (double)doubleForKey:(id)key;
- (BOOL)booleanForKey:(id)key;
- (long)longForKey:(id)key;
- (long long)longLongForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSDictionary *)dictForKey:(id)key;
- (id)safeObjectForKey:(id)key;

@end
