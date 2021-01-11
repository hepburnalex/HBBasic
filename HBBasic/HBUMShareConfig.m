//
//  HBUMShareConfig.m
//  xinghetuoke
//
//  Created by Hepburn on 2021/1/11.
//  Copyright © 2021 Hepburn. All rights reserved.
//

#import "HBUMShareConfig.h"

@implementation HBUMShareConfig

+ (instancetype)instance {
    static HBUMShareConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addWXConfig:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink {
    [HBUMShareConfig instance].wechat = [HBUMShareConfigItem createConfigItem:appKey appSecret:appSecret universalLink:universalLink];
}

- (void)addQQConfig:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink {
    [HBUMShareConfig instance].qq = [HBUMShareConfigItem createConfigItem:appKey appSecret:appSecret universalLink:universalLink];
}

- (void)addSinaConfig:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink {
    [HBUMShareConfig instance].sina = [HBUMShareConfigItem createConfigItem:appKey appSecret:appSecret universalLink:universalLink];
}

@end
