//
//  HBUMShare.m
//  SummitClub
//
//  Created by Hepburn on 2019/9/30.
//  Copyright © 2019 Hepburn. All rights reserved.
//

#import "HBUMShare.h"
#import <UMCommon/UMCommon.h>
#import "WXApi.h"
#import "AFHttpManager.h"
#import "HBUMShareConfig.h"
#import "MBProgressHUD+MJ.h"

@interface HBUMShare ()

@property (nonatomic, strong) NSMutableDictionary *wxParamDict;

@end

@implementation HBUMShare

+ (instancetype)instance {
    static HBUMShare *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/// 初始化
/// @param umengKey 友盟KEY
/// @param checkUniversalLink 是否校验UniversalLink 
- (void)initUMSocial:(NSString *)umengKey checkUniversalLink:(BOOL)checkUniversalLink {
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"TARGET_IPHONE_SIMULATOR");
#else
    //友盟
    [UMConfigure setLogEnabled:YES];//设置打开日志
    [UMConfigure initWithAppkey:umengKey channel:@"App Store"];
    [self configUSharePlatforms:checkUniversalLink];
#endif
}

/// 配置友盟分享
/// @param checkUniversalLink 是否校验UniversalLink
- (void)configUSharePlatforms:(BOOL)checkUniversalLink
{
    [[UMSocialManager defaultManager] openLog:YES];
    NSMutableDictionary *universalLinkDic = [NSMutableDictionary dictionary];
    if ([HBUMShareConfig instance].wechat) {
        [universalLinkDic setObject:[HBUMShareConfig instance].wechat.universalLink forKey:@(UMSocialPlatformType_WechatSession)];
    }
    if ([HBUMShareConfig instance].qq) {
        [universalLinkDic setObject:[HBUMShareConfig instance].qq.universalLink forKey:@(UMSocialPlatformType_QQ)];
    }
    
    [UMSocialGlobal shareInstance].universalLinkDic = universalLinkDic;

    NSString *redirectUrl = @"http://mobile.umeng.com/social";
//    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    if ([HBUMShareConfig instance].wechat) {
        /* 设置微信的appKey和appSecret */
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:[HBUMShareConfig instance].wechat.appKey appSecret:[HBUMShareConfig instance].wechat.appSecret redirectURL:redirectUrl];
    }
    else if ([HBUMShareConfig instance].qq) {
        /* 设置分享到QQ互联的appID */
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:[HBUMShareConfig instance].qq.appKey appSecret:nil redirectURL:redirectUrl];
    }
    else if ([HBUMShareConfig instance].sina) {
        /* 设置新浪的appKey和appSecret */
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:[HBUMShareConfig instance].sina.appKey appSecret:[HBUMShareConfig instance].sina.appSecret redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    }

    if (checkUniversalLink) {
        [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
            NSLog(@"checkUniversalLinkReady:%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
        }];
        [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString * _Nonnull log) {
            NSLog(@"WXApi-->%@", log);
        }];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - 分享

/// 判断whatsApp是否安装
- (BOOL)isWhatsAppInstalled {
    return [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]];
}

/// 安装whatsApp
- (void)showWhatsAppInstall {
    [MTAlert showAlertWithTitle:@"尚未安装WhatsApp" message:nil cancel:@"取消" ok:@"安装" clickBlock:^(NSInteger tag) {
        if (tag == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id310633997"] options:@{} completionHandler:nil];
        }
    }];
}

/// 分享web到whatsApp
/// @param url web链接
/// @param title 标题
/// @param viewController controller
/// @param finishBlock 完毕回调
- (void)shareWebPageToWhatsApp:(NSString *)url title:(NSString *)title viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock {
    if (self.isWhatsAppInstalled) {
        NSString *text = [NSString stringWithFormat:@"%@", url];
        text = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        text = [text stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        url = [NSString stringWithFormat:@"whatsapp://send?text=%@", text];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
    }
    else {
        [self showWhatsAppInstall];
    }
}

/// 分享图片到whatsApp
/// @param title 标题
/// @param desc 描述
/// @param imageurl 图片链接
/// @param thumbImage 缩略图
/// @param viewController controller
/// @param finishBlock 完毕回调
- (void)shareImageToWhatsApp:(NSString *)title desc:(NSString *)desc image:(NSString *)imageurl thumb:(UIImage *)thumbImage viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock {
    if (self.isWhatsAppInstalled) {
        NSString *localpath = [NetImageView getLocalPathOfUrl:imageurl];
        UIImage *image = [UIImage imageWithContentsOfFile:localpath];
        NSString *savePath  = [kCachesPath stringByAppendingPathComponent:@"whatsAppTmp.wai"];
        [UIImageJPEGRepresentation(image, 0.8) writeToFile:savePath atomically:YES];

        NSArray *activityItems = @[[NSURL fileURLWithPath:savePath]];
        UIActivityViewController *ctrl = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        ctrl.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop];

        [viewController presentViewController:ctrl animated:YES completion:nil];
    }
    else {
        [self showWhatsAppInstall];
    }
}

/// 分享web
/// @param platformType 平台
/// @param url web链接
/// @param title 标题
/// @param desc 描述
/// @param image 缩略图
/// @param viewController controller
/// @param finishBlock 完毕回调
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType url:(NSString *)url title:(NSString *)title desc:(NSString *)desc image:(id)image viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock {
    if (platformType == UMSocialPlatformType_Whatsapp) {
        [self shareWebPageToWhatsApp:url title:title viewController:viewController finishBlock:finishBlock];
        return;
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];

    if ([image isKindOfClass:[NSString class]]) {
        NSString *imagename = (NSString *)image;
        NSString *localpath = [NetImageView getLocalPathOfUrl:imagename];
        NSData *data = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:localpath]) {
            data = [NSData dataWithContentsOfFile:localpath];
        }
        if (!data) {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagename]];
        }
        if (data) {
            UIImage *newimage = [UIImage imageWithData:data];
            if (newimage && newimage.size.width>200) {
                float scale = 200.0/newimage.size.width;
                newimage = [newimage scaleImage:scale];
            }
            image = newimage;
        }
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:image];
    shareObject.webpageUrl = url;
    
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }
        else {
            NSLog(@"错误码是 errcode = %d",(int)error.code);
            if (finishBlock) {
                finishBlock();
            }
            [MBProgressHUD showSuccess:@"分享成功"];
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                NSLog(@"response message is %@",resp.message);
                //第三方原始返回的数据
                NSLog(@"response originalResponse data is %@",resp.originalResponse);
            }
            else {
                NSLog(@"response data is %@",data);
            }
        }
    }];
}

/// 分享图片
/// @param platformType 平台
/// @param title 标题
/// @param desc 描述
/// @param imageurl 图片链接
/// @param thumbImage 缩略图
/// @param viewController controller
/// @param finishBlock 完毕回调
- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType title:(NSString *)title desc:(NSString *)desc image:(NSString *)imageurl thumb:(UIImage *)thumbImage viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock {
    if (platformType == UMSocialPlatformType_Whatsapp) {
        [self shareImageToWhatsApp:title desc:desc image:imageurl thumb:thumbImage viewController:viewController finishBlock:finishBlock];
        return;
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:desc thumImage:thumbImage];
    shareObject.shareImage = imageurl;
    
    messageObject.shareObject = shareObject;
    
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }
        else {
            NSLog(@"错误码是 errcode = %d",(int)error.code);
            if (finishBlock) {
                finishBlock();
            }
            [MBProgressHUD showSuccess:@"分享成功"];
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                NSLog(@"response message is %@",resp.message);
                //第三方原始返回的数据
                NSLog(@"response originalResponse data is %@",resp.originalResponse);
            }
            else {
                NSLog(@"response data is %@",data);
            }
        }
    }];
}

/// 分享视频
/// @param platformType 视频
/// @param title 标题
/// @param desc 描述
/// @param videoUrl 视频链接
/// @param thumbImage 缩略图
/// @param viewController controller
/// @param finishBlock 完毕回调
- (void)shareVideoToPlatformType:(UMSocialPlatformType)platformType title:(NSString *)title desc:(NSString *)desc video:(NSString *)videoUrl thumb:(UIImage *)thumbImage viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock {
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:desc thumImage:thumbImage];
    shareObject.videoUrl = videoUrl;
    
    messageObject.shareObject = shareObject;
    
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }
        else {
            NSLog(@"错误码是 errcode = %d",(int)error.code);
            if (finishBlock) {
                finishBlock();
            }
            [MBProgressHUD showSuccess:@"分享成功"];
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                NSLog(@"response message is %@",resp.message);
                //第三方原始返回的数据
                NSLog(@"response originalResponse data is %@",resp.originalResponse);
            }
            else {
                NSLog(@"response data is %@",data);
            }
        }
    }];
}

/// 第三方登录
/// @param platformType 平台
/// @param viewController controller
/// @param finishBlock 完毕回调
- (void)loginToPlatformType:(UMSocialPlatformType)platformType viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(NSDictionary *))finishBlock {
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:viewController completion:^(id result, NSError *error) {
        NSLog(@"%@, %@", result, error);
        NSMutableDictionary *dict = nil;
        if (!error) {
            dict = [NSMutableDictionary dictionary];
            UMSocialUserInfoResponse *response = (UMSocialUserInfoResponse *)result;
            [dict setObject:response.name forKey:@"name"];
            [dict setObject:response.iconurl forKey:@"avatar"];
            [dict setObject:response.unionId forKey:@"unionId"];
            [dict setObject:response.openid forKey:@"openId"];
            if (platformType == UMSocialPlatformType_WechatSession) {
                self.wxParamDict = dict;
                [self loadWXUserDetail:response.accessToken unionId:response.unionId finishBlock:finishBlock];
                return;
            }
        }
        if (finishBlock) {
            finishBlock(dict);
        }
    }];
}

/// 获取微信用户详情
/// @param accessToken accessToken
/// @param unionId unionId
/// @param finishBlock 完成回调
- (void)loadWXUserDetail:(NSString *)accessToken unionId:(NSString *)unionId finishBlock:(nullable void(^)(NSDictionary *))finishBlock {
    NSString *urlstr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, unionId];
    [AFHttpManager GET:urlstr parameters:nil success:^(id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"%s %@", __func__, dict);
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            [self.wxParamDict setObject:dict[@"province"] forKey:@"province"];
            [self.wxParamDict setObject:dict[@"country"] forKey:@"country"];
            [self.wxParamDict setObject:dict[@"city"] forKey:@"city"];
            [self.wxParamDict setObject:dict[@"language"] forKey:@"language"];
            if (finishBlock) {
                finishBlock(self.wxParamDict);
            }
        }
        else {
            if (finishBlock) {
                finishBlock(self.wxParamDict);
            }
        }
    } failure:^(NSError *error) {
        if (finishBlock) {
            finishBlock(self.wxParamDict);
        }
    } root:nil];
}

@end
