//
//  ViewController.m
//  ZYDataBaseToolDemo
//
//  Created by ZYSu on 2017/6/24.
//  Copyright © 2017年 ZYSu. All rights reserved.
//

#import "ViewController.h"
#import "ZYDatabase.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 是时候开始你的表演了...
//    [self testInsert];
    
    [self testQuery];
    
//    [self testUpdate];
    
//    [self testDelete];
    
}

- (void)testInsert
{
    // 插入数据
    BOOL res = DB.table(@"User").insert(@{@"name" : @"张三", @"age" : @22, @"sex" : [NSNull null]});
    res = DB.table(@"User").insert(@{@"name" : @"李四", @"age" : @22, @"sex" : @"男"});
    res = DB.table(@"User").insert(@{@"name" : @"", @"age" : @22, @"sex" : @"女"});
}

- (void)testQuery
{
    NSDictionary *dict = DB.table(@"User").orderBy(@"name", @"DESC").orderBy(@"name", nil).orderBy(@"age", @"AAA").orderBy(@"name", @"ASC").first();
    NSLog(@"%@", dict);
    
    
    NSInteger age = DB.table(@"User").first_map(@"age").integerValue;
    NSLog(@"age : %zd", age);
    
    NSArray *all = DB.table(@"User").all();
    NSLog(@"%@", all);
    
    NSArray *ages = DB.table(@"User").all_map(^id(NSDictionary *dict) {
        return [dict objectForKey:@"age"];
    });
    
    NSLog(@"%@", ages);
}

- (void)testUpdate
{
    DB.table(@"User").where(@[@"name", @"=", @"张三"]).update(@{@"sex" : @"未知"});
}

- (void)testDelete
{
    DB.table(@"User").delete();
}

@end
