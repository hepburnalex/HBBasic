//
//  ViewController.m
//  HBBasic
//
//  Created by Hepburn on 2020/10/16.
//

#import "ViewController.h"
#import "AFHttpManager.h"
#import "MBProgressHUD+MJ.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton CreateTextButton:@"测试" font:UISystemFont(14) titleColor:[UIColor blackColor]];
    btn.backgroundColor = [UIColor yellowColor];
    [btn addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        kMAS_TOP(self.view, 60);
        kMAS_LEFT(self.view, 40);
        kMAS_SIZES(80, 40);
    }];
}

- (void)onButtonClick {
    [AFHttpManager POST:@"http://api.summitdigitalcloud.com/api2/user/get_setting" parameters:@{@"uid":@"7"} success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"成功" toView:self.view];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"失败" toView:self.view];
    } root:self];
}


@end
