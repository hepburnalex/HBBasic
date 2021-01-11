//
//  HBUMShare.h
//  SummitClub
//
//  Created by Hepburn on 2019/9/30.
//  Copyright © 2019 Hepburn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBUMShare : NSObject

@property (nonatomic, readonly) BOOL isWhatsAppInstalled;

+ (instancetype)instance;

/// 初始化
/// @param umengKey 友盟KEY
/// @param checkUniversalLink 是否校验UniversalLink
- (void)initUMSocial:(NSString *)umengKey checkUniversalLink:(BOOL)checkUniversalLink;

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType url:(NSString *)url title:(NSString *)title desc:(NSString *)desc image:(id)image viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock;

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType title:(NSString *)title desc:(NSString *)desc image:(NSString *)imageurl thumb:(nullable UIImage *)thumbImage viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock;

- (void)shareVideoToPlatformType:(UMSocialPlatformType)platformType title:(NSString *)title desc:(NSString *)desc video:(NSString *)videoUrl thumb:(UIImage *)thumbImage viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock;

- (void)loginToPlatformType:(UMSocialPlatformType)platformType viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(NSDictionary *))finishBlock;

- (void)shareWebPageToWhatsApp:(NSString *)url title:(NSString *)title viewController:(UIViewController *)viewController finishBlock:(nullable void(^)(void))finishBlock;
@end

NS_ASSUME_NONNULL_END
