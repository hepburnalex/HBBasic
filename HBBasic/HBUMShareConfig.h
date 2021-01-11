//
//  HBUMShareConfig.h
//  xinghetuoke
//
//  Created by Hepburn on 2021/1/11.
//  Copyright © 2021 Hepburn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBUMShareConfigItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBUMShareConfig : NSObject

@property (nonatomic, strong) HBUMShareConfigItem *wechat;
@property (nonatomic, strong) HBUMShareConfigItem *qq;
@property (nonatomic, strong) HBUMShareConfigItem *sina;

+ (instancetype)instance;

- (void)addWXConfig:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink;
- (void)addQQConfig:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink;
- (void)addSinaConfig:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink;

@end

NS_ASSUME_NONNULL_END
