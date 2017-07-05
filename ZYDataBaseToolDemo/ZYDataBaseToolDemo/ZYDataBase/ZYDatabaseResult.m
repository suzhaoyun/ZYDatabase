//
//  ZYDatabaseResult.m
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/7/5.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ZYDatabaseResult.h"
#import "NSDictionary+ZYSafe.h"

@interface ZYDatabaseResult()

@property (nonatomic, strong) NSDictionary *dict;

@property (nonatomic, copy) NSString *key;

@end

@implementation ZYDatabaseResult

+ (instancetype)databaseResult:(NSDictionary *)dict key:(NSString *)key
{
    ZYDatabaseResult *rs = [[self alloc] init];
    rs.dict = dict;
    rs.key = key;
    return rs;
}

- (NSString *)stringValue
{
    return [self.dict stringForKey:self.key];
}

- (NSDictionary *)dictValue
{
    return [self.dict dictForKey:self.key];
}

- (NSArray *)arrayValue
{
    return [self.dict arrayForKey:self.key];
}

- (float)floatValue
{
    return [self.dict doubleForKey:self.key];
}

- (double)doubleValue
{
    return [self.dict doubleForKey:self.key];
}

- (NSInteger)integerValue
{
    return [self.dict integerForKey:self.key];
}

- (long)longValue
{
    return [self.dict longForKey:self.key];
}

- (NSData *)dataValue
{
    NSData *data = [self.dict safeObjectForKey:self.key];
    if ([data isKindOfClass:[NSData class]]) {
        return data;
    }
    return nil;
}

- (BOOL)boolValue
{
    return [self.dict booleanForKey:self.key];
}

@end
