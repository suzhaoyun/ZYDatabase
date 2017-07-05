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
//    ZYTable(@"User").insert(@{@"name" : @"hehe", @"age" : @20, @"sex" : @"男"});
    return;
    [DB inTransaction:^(BOOL *rollback) {
        ZYTable(@"").select(nil).update(nil);
        ZYTable(nil).update(nil);
    }];
    
    ZYTable(nil).first_map(nil);
    
    ZYTable(@"User").all_map(^id(NSDictionary *obj) {
        return [obj objectForKey:@"name"];
    });
    return;
    return;
    
    DB.table(@"").where(@{@"" : @3}).andWhere(@{@"":@""}).all();
    
    DB.table(@"").join(@"b", @{@"name" : @"name", @"" : @""}).insert(@{});
    
    DB.table(@"").where(@{}).update(@{});
    
    DB.table(@"luge").insert(@{@"name" : @"xxxx", @"age" : @2});
    
    NSArray *array = DB.table(@"luge").where(@{@"name" : @"xxxx"}).all();
    [array count];
    
    DB.table(@"xxx").where(@[@"name", @"=", @"xxxx", @"age", @">", @"0"]).delete();
    
    DB.table(@"").where(nil).where(nil).andWhere(nil).join(nil, nil).update(nil);
    
    DB.table(@"").where(@{@"name" : @"zhangsan"}).first(@"");
    
    ZYTable(@"").where(nil).andWhere(@{}).delete();
    
    ZYTable(@"").where(nil).update(@{});
    
    ZYTable(@"").where(@{@"name" : @"zhangsan"}).delete();
    
    DB.table(@"").where(@{}).groupBy(@"name").select(@[@"name as a"]).having(@{@"a" : @"name"}).limit(@"3").first(nil);
    
    ZYTable(@"").where(@{@"id" : @100}).first(nil);
    
    
    DB.table(@"").where(@[@"name", @"=", @"abd"]).delete();
    
    DB.table(nil).join(@"b", @{@"a" : @"b"}).select(@[@"a.name", @"b.name"]).orderBy(@"", @"ASC").all();
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"你看" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
