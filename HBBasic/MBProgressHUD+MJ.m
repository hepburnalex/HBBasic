//
//  MBProgressHUD+MJ.h
//  HBBasic
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"

@implementation MBProgressHUD (MJ)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (!view) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    if (icon) {
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"org.cocoapods.HBBasic"];
        NSString *path = [bundle pathForResource:@"MBProgressHUD" ofType:@"bundle"];
        NSBundle *targetBundle = [NSBundle bundleWithPath:path];
        UIImage *image = [UIImage imageNamed:icon
                                    inBundle:targetBundle
               compatibleWithTraitCollection:nil];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // 再设置模式
        hud.mode = MBProgressHUDModeCustomView;
    }
    else {
        hud.label.numberOfLines = 0;
        hud.mode = MBProgressHUDModeText;
    }
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
}

#pragma mark 显示错误信息

+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"mb_success" view:view];
}

+ (void)showError:(NSString *)error toView:(UIView *)view {
    [self show:error icon:@"mb_error" view:view];
}

+ (void)showTips:(NSString *)tips toView:(UIView *)view {
    [self show:tips icon:nil view:view];
}

+ (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showError:(NSString *)success {
    [self showError:success toView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showTips:(NSString *)tips {
    [self showTips:tips toView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (!view) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (MBProgressHUD *)showMessage:(NSString *)message {
    return [self showMessage:message toView:[UIApplication sharedApplication].keyWindow];
}

@end
