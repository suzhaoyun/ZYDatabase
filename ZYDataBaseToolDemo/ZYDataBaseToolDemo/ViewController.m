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
//     DB.table(@"User").insert(@{@"name" : @"hehe", @"age" : @20, @"sex" : @"男"});
//    DB.table(@"User").orWhere(@[@"name", @"LIKE", @"%su%", @"age", @">", @22]).where(@{@"name" : @3, @"age" : @4}).orWhere(@"age = 3 OR name like '_l%'").delete();
    
    DB.table(@"User").orWhere(@[@"name", @"LIKE", @"%su%", @"age", @">", @22]).orWhere(@{@"name" : @"li"}).delete();
    return;
    [DB inTransaction:^(BOOL *rollback) {
        DB.table(nil).select(nil).update(nil);
        DB.table(nil).update(nil);
    }];
    
    DB.table(nil).first_map(nil);
    
    DB.table(nil).all_map(^id(NSDictionary *obj) {
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
    
    DB.table(nil).where(nil).andWhere(@{}).delete();
    
    DB.table(nil).where(nil).update(@{});
    
    DB.table(nil).where(@{@"name" : @"zhangsan"}).delete();
    
    DB.table(@"").where(@{}).groupBy(@"name").select(@[@"name as a"]).having(@{@"a" : @"name"}).limit(@"3").first(nil);
    
    DB.table(nil).where(@{@"id" : @100}).first(nil);
    
    
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
