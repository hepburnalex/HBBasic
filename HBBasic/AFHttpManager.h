//
//  AFHttpManager.h
//  HBBasic
//
//  Created by Hepburn on 2018/7/26.
//  Copyright © 2018年 Hepburn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HBBasicLib/HBBasicLib.h>

@interface AFHttpManager : NSObject

// Get请求
+ (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post form
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post form
+ (NSURLSessionDataTask *)POST2:(NSString *)URLString parameters:(id)parameters success:(void (^)(int code, id respObj, NSString *msg))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post 图片
+ (NSURLSessionDataTask *)POSTImage:(NSString *)URLString parameters:(id)parameters image:(UIImage *)image imagename:(NSString *)imagename success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post 多张图片
+ (NSURLSessionDataTask *)POSTImages:(NSString *)URLString parameters:(id)parameters images:(NSArray<UIImage *> *)images imagename:(NSString *)imagename success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post 文件
+ (NSURLSessionDataTask *)POSTFile:(NSString *)URLString parameters:(id)parameters filepath:(NSString *)filePath name:(NSString *)name success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post raw
+ (void)POST:(NSString *)URLString body:(NSData *)body success:(void(^)(id response))success failure:(void(^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// Post Json
+ (void)POSTJSON:(NSString *)URLString params:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

// 下载文件
+ (void)DownloadFile:(NSString *)urlstr success:(void (^)(NSString *path, NSString *url))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl;

+ (NSString *)GetLocalPathOfUrl:(NSString *)urlstr;
+ (BOOL)IsLocalPathExist:(NSString *)urlstr;

@end
