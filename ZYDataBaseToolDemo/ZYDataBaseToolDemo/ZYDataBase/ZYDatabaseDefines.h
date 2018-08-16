//
//  ZYDatabaseType.h
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 ZYSu. All rights reserved.
//
#import <UIKit/UIKit.h>
#define DB [ZYDatabaseHandler sharedInstace]

@class ZYDatabaseHandler;
typedef ZYDatabaseHandler  * (^OneStringType)(NSString *args);
typedef ZYDatabaseHandler  * (^OneDictType)(NSDictionary *args);
typedef ZYDatabaseHandler  * (^OneArrayType)(NSArray *args);
typedef ZYDatabaseHandler  * (^OneObjectType)(id args);
typedef ZYDatabaseHandler  * (^JoinType)(NSString *tableName, NSDictionary *onConditions);
typedef ZYDatabaseHandler  * (^OrderByType)(NSString *column, NSString *sortType);
typedef BOOL (^VoidType)();
typedef BOOL (^DDLType)(NSString *sql);
typedef BOOL (^InsertUpdateType)(NSDictionary *args);
typedef NSDictionary * (^FirstType)();
typedef id (^FilterMapArgsType)(NSDictionary *dict);
typedef ZYDatabaseHandler  * (^FilterMapType)(FilterMapArgsType type);
typedef ZYDatabaseHandler * (^DistinctType)();
typedef NSArray<NSDictionary *> * (^MutipleType)();
typedef NSInteger (^CountType)();

extern NSString * const CreateConst;
extern NSString * const DropConst;
extern NSString * const AlterConst;
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
