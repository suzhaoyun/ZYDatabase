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
    // Do any additional setup after loading the view, typically from a nib.
    
    // 是时候开始你的表演了...
    ZYTable(@"User").insert(@{@"name" : @"hehe"});
    return;
    DB.table(@"t_name").where(@[self.nibName, @"=", @3]).andWhere(@"").orWhere(@"").orderBy(nil).groupBy(@"").delete().booleanValue;
    
    DB.table(@"").where(@{@"" : @3}).andWhere(@{@"":@""}).get(@"isFiend").booleanValue;
    
    DB.table(@"").join(@"b", @{@"name" : @"name", @"" : @""}).insert(@{});
    
    DB.table(@"").where(@{}).update(@{});
    
    DB.table(@"luge").insert(@{@"name" : @"xxxx", @"age" : @2}).booleanValue;
    
    NSArray *array = DB.table(@"luge").where(@{@"name" : @"xxxx"}).get(nil).arrayValue;
    [array count];
    
    DB.table(@"xxx").where(@[@"name", @"=", @"xxxx", @"age", @">", @"0"]).delete();
    
    DB.table(@"").where(nil).where(nil).andWhere(nil).join(nil, nil).update(nil);
    
    DB.table(@"").where(@{@"name" : @"zhangsan"}).first(@"");
    
    ZYTable(@"").where(nil).andWhere(@{}).delete();
    
    ZYTable(@"").where(nil).update(@{});
    
    ZYTable(@"").where(@{@"name" : @"zhangsan"}).delete();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
