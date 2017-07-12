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
    
//    [self testDelete];
    
//    [self testInsert];
    
    [self testQuery];
    
//    [self testUpdate];
    
//    [self testDelete];
    
//    [self testGroupBy];
    
//    [self testJoin];
}

- (void)testInsert
{
    // 插入数据
    BOOL res = DB.table(@"User").insert(@{@"name" : @"张三", @"age" : @22, @"sex" : [NSNull null], @"car_id" : @1});
    NSLog(@"%d", res);
    
    DB.table(@"User").insert(@{@"name" : @"李四", @"age" : @22, @"sex" : @"男",@"car_id" : @3});
    DB.table(@"User").insert(@{@"name" : @"", @"age" : @22, @"sex" : @"女"});
    
    DB.table(@"User").insert(@{@"name" : @"嘻嘻", @"age" : @10, @"sex" : @"女",@"car_id" : @2});
    
    DB.table(@"User").insert(@{@"name" : @"啦啦", @"age" : @12, @"sex" : @"男", @"car_id" : @3});
    
    DB.table(@"User").insert(@{@"name" : @"呵呵", @"age" : @80, @"sex" : @"不知道"});
    
    DB.table(@"Car").insert(@{@"name" : @"奥迪", @"price" : @"400000"});
    DB.table(@"Car").insert(@{@"name" : @"大众", @"price" : @"200000"});
    DB.table(@"Car").insert(@{@"name" : @"奔驰", @"price" : @"1000000"});
    DB.table(@"Car").insert(@{@"name" : @"玛莎", @"price" : @"10000000"});
}

- (void)testQuery
{
    
    NSInteger count = DB.table(@"User").distinct().count();
    NSLog(@"查到了%zd条数据", count);
    
    NSDictionary *dict = DB.table(@"User").where(@{@"age" : @22}).orWhere(@[@"age", @"<", @"100"]).orderBy(@"name", @"DESC").orderBy(@"name", nil).orderBy(@"age", @"").orderBy(@"name", @"ASC").first();
    NSLog(@"%@", dict);
    
    
    NSInteger age = DB.table(@"User").first_(@"age").integerValue;
    NSLog(@"age : %zd", age);
    
    NSArray *all = DB.table(@"User").all();
    NSLog(@"%@", all);
    
    NSArray *ages = DB.table(@"User").all_(^id(NSDictionary *dict) {
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

- (void)testGroupBy
{
    NSDictionary *rs = DB.table(@"User").select(@"age, count(*) as c").groupBy(@"age").having(@"c = 1").distinct().first();
    
    NSLog(@"%@", rs);
    
    DB.table(@"User").distinct().all_(^id(NSDictionary *dict) {
        return nil;
    });
    
}

- (void)testJoin
{
    NSString *name = DB.table(@"User").join(@"Car", @{@"Car.id":@"User.car_id"}).select(@"Car.name").where(@"age = 23 OR Car.name like '%s'").where(@{@"age" : @3}).orWhere(@{@"age" : @22}).orWhere(@[@"Car.name" , @"in", @[@"zhangsna", @"sfdf"], @"age", @">=", @23]).first_(@"Car.name").stringValue;
    NSLog(@"%@", name);
    
    NSArray *all = DB.table(@"User as u").leftJoin(@"Car as c", @{@"u.car_id" : @"c.id"}).all();
    NSLog(@"%@", all);
}

@end
