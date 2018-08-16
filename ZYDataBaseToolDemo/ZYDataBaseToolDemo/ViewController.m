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
    // 创建数据库
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"demo.sqlite"];
    
    [DB createDatabaseWithPath:path];
    
    // 创建表
    DB.table(@"student").create(@"name text not null, age int default 0, school_id varchar(100)");
    DB.table(@"school").create(@"name text not null, address text, school_id text not null");
    
    DB.table(@"school").alter(@"add column school_id text not null");
    
    // 插入数据
    // [self testInsert];
    
    // 查询数据
    NSLog(@"%@", DB.table(@"student").all());
    NSLog(@"%@", DB.table(@"school").all());

    NSDictionary *r1 = DB.table(@"student").where(@{@"name" : @"张三"}).first();
    NSLog(@"%@", r1);
    
    // 这里需要注意FMDB中多表关联有相同字段的时候必须指定别名
    NSDictionary *r2 = DB.table(@"student as stu").join(@"school as sch", @{@"stu.school_id" : @"sch.school_id"}).select(@"stu.name as stuname, sch.name as schoolname").where(@{@"stu.name":@"赵六"}).first();
    NSLog(@"%@", r2);
    
    // 单条查询
    DB.table(@"student").where(@{@"age" : @0}).first();

    // 多条查询
    DB.table(@"student").where(@{@"age" : @0}).all();
    
    // 复杂条件 where支持三种参数 具体可查看api说明
    DB.table(@"student").where(@[@"name", @"like", @"%芳%"]).orWhere(@{@"age" : @18}).andWhere(@{@"school_id":@1}).all();
    
    // 排序
    DB.table(@"student").orderBy(@"age", @"DESC").all();
    // 统计数目
    DB.table(@"student").count();
    // 分组
    DB.table(@"student").groupBy(@"age").having(@"age > 18").all();
    // limit语句
    DB.table(@"student").limit(@"0, 2").all();
    // 多表关联...
    DB.table(@"student as stu").join(@"school as sch", @{@"school_id":@"school_id"}).all();
    // 自定义数据过滤
    DB.table(@"student").where(@{@"age" : @0}).filtermap(^id(NSDictionary *dict) {
        // 例如可以在这里进行字典转模型
        
        // 也可以把数据过滤掉 return nil即可
        
        return dict;
    }).all();
    
    // 插入新数据
    DB.table(@"student").insert(@{@"name" : @"Tom", @"age" : @22, @"school_id" : @1});
    
    // 删除
    DB.table(@"student").where(@"name = '张三'").delete();
    
    // 更新
    DB.table(@"student").where(@{@"name" : @"张三"}).update(@{@"name" : @"李四"});
}

- (void)testInsert
{
    DB.table(@"student").insert(@{@"name" : @"张三", @"age" : @21, @"school_id" : @1});
    DB.table(@"student").insert(@{@"name" : @"李四", @"age" : @22, @"school_id" : @2});
    DB.table(@"student").insert(@{@"name" : @"王五", @"age" : @23, @"school_id" : @1});
    DB.table(@"student").insert(@{@"name" : @"赵六", @"age" : @24, @"school_id" : @2});
    
    DB.table(@"school").insert(@{@"school_id": @"1", @"name" : @"济南大学", @"address" : @"二环南路"});
    DB.table(@"school").insert(@{@"school_id": @"2", @"name" : @"山东大学", @"address" : @"洪家楼"});
}

@end
