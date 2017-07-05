//
//  NSDictionary+ZY
//  ZY
//
//  Created by ZY on 15/6/8.
//  Copyright (c) 2015年 苏兆云. All rights reserved.
//

#import "NSDictionary+ZYSafe.h"

@implementation NSDictionary (ZYSafe)

- (NSString *)stringForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if ([value isKindOfClass:[NSString class]]){
        return value;
    }else if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }else{
        return nil;
    }
}

- (NSInteger)integerForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

- (double)doubleForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0.0;
}

- (BOOL)booleanForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

- (long)longForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value respondsToSelector:@selector(longValue)]) {
        return [value longValue];
    }
    return 0;
}

- (long long)longLongForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value respondsToSelector:@selector(longLongValue)]) {
        return [value longLongValue];
    }
    return 0;
}

- (NSArray *)arrayForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}
- (NSDictionary *)dictForKey:(id)key
{
    id value = [self safeObjectForKey:key];
    if (value && [value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (id)safeObjectForKey:(id)key
{
    id value = [self objectForKey:key];
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

@end
