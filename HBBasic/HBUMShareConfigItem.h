//
//  HBUMShareConfigItem.h
//  xinghetuoke
//
//  Created by Hepburn on 2021/1/11.
//  Copyright © 2021 Hepburn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBUMShareConfigItem : NSObject

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *universalLink;

+ (HBUMShareConfigItem *)createConfigItem:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink;

@end

NS_ASSUME_NONNULL_END
