//
//  AFHttpManager.m
//  HBBasic
//
//  Created by Hepburn on 2018/7/26.
//  Copyright © 2018年 Hepburn. All rights reserved.
//

#import "AFHttpManager.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreServices/CoreServices.h>
#import <MJExtension.h>

#define Timeout 30

@implementation AFHttpManager

#pragma mark - 单例get
+ (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    NSString *url = URLString;
    if ([parameters count] > 0)
        NSLog(@"%@?%@", url, [AFHttpManager appendParameters:parameters]);
    else
        NSLog(@"%@",url);
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return nil;
        }
        [rootctrl startLoading];
    }
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];;
    session.requestSerializer.timeoutInterval = Timeout;
    
    return [session GET:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (task.state != NSURLSessionTaskStateCompleted) {
            NSLog(@"请求失败---------%@",error);
            if (failure) {
                failure(error);
            }
            [MTAlert showAlertWithTitle:@"提示" message:@"网络连接失败" cancel:nil ok:@"确定" clickBlock:nil];
        }
    }];
}

#pragma mark - 单例post/form
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    NSString *url = URLString;
    if ([parameters count] > 0)
        NSLog(@"%@?%@", url, [AFHttpManager appendParameters:parameters]);
    else
        NSLog(@"%@",url);
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return nil;
        }
        [rootctrl startLoading];
    }
        
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];;
    session.requestSerializer.timeoutInterval = Timeout;

//    NSLog(@"%@", session.requestSerializer.HTTPRequestHeaders);

    NSURLSessionDataTask *task = [session POST:url parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (rootctrl) {
                [rootctrl stopLoading];
            }
            if (success) {
                success(responseObject);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (failure) {
            failure(error);
        }
        if (task.state != NSURLSessionTaskStateCompleted) {
            NSLog(@"请求失败---------%@",error);
            [MTAlert showAlertWithTitle:@"提示" message:@"网络连接失败" cancel:nil ok:@"确定" clickBlock:nil];
        }
    }];
//    NSLog(@"%@", task.originalRequest.allHTTPHeaderFields);
    return task;
}

#pragma mark - 单例post/form
+ (NSURLSessionDataTask *)POST2:(NSString *)URLString parameters:(id)parameters success:(void (^)(int code, id respObj, NSString *msg))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    return [AFHttpManager POST:URLString parameters:parameters success:^(id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"%s %@", __func__, dict);
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            int iCode = [dict[@"code"] intValue];
            if (success) {
                success(iCode, dict[@"data"], dict[@"message"]);
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __func__, error);
        if (failure) {
            failure(error);
        }
    } root:rootctrl];
}

#pragma mark - 单例post/raw
+ (void)POST:(NSString *)URLString body:(NSData *)body success:(void(^)(id response))success failure:(void(^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    NSString *url = URLString;
    NSLog(@"%@",url);
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return;
        }
        [rootctrl startLoading];
    }
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    request.timeoutInterval= Timeout;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // 设置body
    [request setHTTPBody:body];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                 @"text/html",
                                                 @"text/json",
                                                 @"text/javascript",
                                                 @"text/plain",
                                                 nil];
    manager.responseSerializer = responseSerializer;
    
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (!error) {
            NSString *respString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if (respString) {
                NSDictionary *respDict = [respString mj_JSONObject];
                if (respDict) {
                    if (success) {
                        success(respDict);
                    }
                    return;
                }
            }
            if (failure) {
                failure(error);
            }
        } else {
            if (failure) {
                failure(error);
            }
            NSLog(@"请求失败---------%@",error);
            [MTAlert showAlertWithTitle:@"提示" message:@"网络连接失败" cancel:nil ok:@"确定" clickBlock:nil];
        }
    }] resume];
}

// Post Json
+ (void)POSTJSON:(NSString *)URLString params:(NSDictionary *)params success:(void(^)(id response))success failure:(void(^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    if (params) {
        NSString *paramsjson = [params mj_JSONString];
        NSData *data = [paramsjson dataUsingEncoding:NSUTF8StringEncoding];
        [AFHttpManager POST:URLString body:data success:success failure:failure root:rootctrl];
    }
}

#pragma mark - 单例post/图片
+ (NSURLSessionDataTask *)POSTImage:(NSString *)URLString parameters:(id)parameters image:(UIImage *)image imagename:(NSString *)imagename success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    
    NSString *url = URLString;
    if ([parameters count] > 0)
        NSLog(@"%@?%@", url, [AFHttpManager appendParameters:parameters]);
    else
        NSLog(@"%@",url);
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return nil;
        }
        [rootctrl startLoading];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);

    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", @"application/octet-stream", nil];
    session.requestSerializer.timeoutInterval = Timeout;
    return  [session POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:imagename fileName:@"uploadimage.jpg" mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success %@", responseObject);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Fail %@", error);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (task.state != NSURLSessionTaskStateCompleted) {
            NSLog(@"请求失败---------%@",error);
            if (failure) {
                failure(error);
            }
            [MTAlert showAlertWithTitle:@"提示" message:@"网络连接失败" cancel:nil ok:@"确定" clickBlock:nil];
        }
    }];
}


+ (NSURLSessionDataTask *)POSTImages:(NSString *)URLString parameters:(id)parameters images:(NSArray<UIImage *> *)images imagename:(NSString *)imagename success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    NSString *url = URLString;
    if ([parameters count] > 0)
        NSLog(@"%@?%@", url, [AFHttpManager appendParameters:parameters]);
    else
        NSLog(@"%@",url);
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return nil;
        }
        [rootctrl startLoading];
    }
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", @"application/octet-stream", nil];
    session.requestSerializer.timeoutInterval = Timeout;
    
    return  [session POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < images.count; i ++) {
            NSData *imageData = UIImageJPEGRepresentation(images[i], 0.7);
            NSString *name = [NSString stringWithFormat:@"%@[%d]", imagename, i+1];
            NSString *fileName = [NSString stringWithFormat:@"uploadimage%d.jpg", i+1];
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success %@", responseObject);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Fail %@", error);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (task.state != NSURLSessionTaskStateCompleted) {
            NSLog(@"请求失败---------%@",error);
            if (failure) {
                failure(error);
            }
            [MTAlert showAlertWithTitle:@"提示" message:@"网络连接失败" cancel:nil ok:@"确定" clickBlock:nil];
        }
    }];
}

+ (NSString *)mimeTypeForPath:(NSString *)path {
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    CFRelease(UTI);
    return mimetype;
}

#pragma mark - 单例post/文件
+ (NSURLSessionDataTask *)POSTFile:(NSString *)URLString parameters:(id)parameters filepath:(NSString *)filePath name:(NSString *)name success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    
    NSString *url = URLString;
    if ([parameters count] > 0)
        NSLog(@"%@?%@", url, [AFHttpManager appendParameters:parameters]);
    else
        NSLog(@"%@",url);
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return nil;
        }
        [rootctrl startLoading];
    }
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileName = [filePath lastPathComponent];
    NSString *mimeType = [AFHttpManager mimeTypeForPath:filePath];
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", @"application/octet-stream", nil];
    session.requestSerializer.timeoutInterval = Timeout;
    return  [session POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSLog(@"%d %@ %@ %@", (int)fileData.length, name, fileName, mimeType);
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success %@", responseObject);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Fail %@", error);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (task.state != NSURLSessionTaskStateCompleted) {
            NSLog(@"请求失败---------%@",error);
            if (failure) {
                failure(error);
            }
            [MTAlert showAlertWithTitle:@"提示" message:@"网络连接失败" cancel:nil ok:@"确定" clickBlock:nil];
        }
    }];
}

#pragma mark - 单例下载文件
//下载文件
+ (void)DownloadFile:(NSString *)urlstr success:(void (^)(NSString *path, NSString *url))success failure:(void (^)(NSError *error))failure root:(BaseADViewController *)rootctrl {
    if ([AFHttpManager IsLocalPathExist:urlstr]) {
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    if (rootctrl) {
        if (rootctrl.isLoading) {
            return;
        }
        [rootctrl startLoading];
    }
    NSURL *URL = [NSURL URLWithString:urlstr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        NSLog(@"%@", documentsDirectoryURL);
//        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        NSString *path = [AFHttpManager GetLocalPathOfUrl:urlstr];
//        NSLog(@"File downloading: %@", path);
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@ %@", filePath.path, response.URL);
        if (rootctrl) {
            [rootctrl stopLoading];
        }
        if (error) {
            if (failure) {
                failure(error);
            }
        }
        else {
            if (success) {
                success(filePath.path, response.URL.absoluteString);
            }
        }
    }];
    [downloadTask resume];
}

#pragma mark - 下载地址

+ (NSString *)MD5String:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)GetLocalPathOfUrl:(NSString *)path {
    if (!path || ![path isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSRange headrange1 = [path rangeOfString:@"http:" options:NSCaseInsensitiveSearch];
    NSRange headrange2 = [path rangeOfString:@"https:" options:NSCaseInsensitiveSearch];
    if (headrange1.length == 0 && headrange2.length == 0) {
        return path;
    }
    NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
    NSString *extname = [path substringFromIndex:range.location+range.length];
    if (extname.length >= 4) {
        extname = @"jpg";
    }
    NSString *name = [AFHttpManager MD5String:path];
    
    NSString *localpath = [kCachesPath stringByAppendingPathComponent:name];
    return [localpath stringByAppendingFormat:@".%@", extname];
}

+ (BOOL)IsLocalPathExist:(NSString *)urlstr {
    NSString *path = [AFHttpManager GetLocalPathOfUrl:urlstr];
    if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

#pragma mark - 拼接请求链接
+(NSString *)appendParameters:(id)parameters{
    NSDictionary *dict = (NSDictionary *)parameters;
    NSArray *allKeys = dict.allKeys;
    NSString *string = @"";
    for (NSString *key in allKeys) {
        string = [string stringByAppendingFormat:@"%@%@=%@", string.length==0?@"":@"&", key,dict[key]];
    }
    return string;
}

@end
