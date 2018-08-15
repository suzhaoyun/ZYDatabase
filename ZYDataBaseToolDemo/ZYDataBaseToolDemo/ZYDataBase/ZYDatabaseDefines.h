//
//  ZYDatabaseType.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 ZYSu. All rights reserved.
//
#import <UIKit/UIKit.h>

@class ZYDatabaseScheduler;
#define DB [ZYDatabaseScheduler sharedInstace]
typedef ZYDatabaseScheduler  * (^OneStringType)(NSString *args);
typedef ZYDatabaseScheduler  * (^OneDictType)(NSDictionary *args);
typedef ZYDatabaseScheduler  * (^OneArrayType)(NSArray *args);
typedef ZYDatabaseScheduler  * (^OneObjectType)(id args);
typedef ZYDatabaseScheduler  * (^JoinType)(NSString *tableName, NSDictionary *onConditions);
typedef ZYDatabaseScheduler  * (^OrderByType)(NSString *column, NSString *sortType);

typedef BOOL (^VoidType)();
typedef BOOL (^InsertUpdateType)(NSDictionary *args);
typedef NSDictionary * (^FirstType)();
typedef id (^FilterMapArgsType)(NSDictionary *dict);
typedef ZYDatabaseScheduler  * (^FilterMapType)(FilterMapArgsType type);
typedef ZYDatabaseScheduler * (^DistinctType)();
typedef NSArray<NSDictionary *> * (^MutipleType)();
typedef NSInteger (^CountType)();

extern NSString * const WhereConst;
extern NSString * const UpdateConst;
extern NSString * const DeleteConst;
extern NSString * const InsertConst;
extern NSString * const SelectConst;
extern NSString * const DistinctConst;
extern NSString * const JoinConst;
extern NSString * const LeftJoinConst;
extern NSString * const RightJoinConst;
extern NSString * const OrderByConst;
extern NSString * const GroupByConst;
extern NSString * const HavingConst;
extern NSString * const ONConst;
