//
//  HBUMShareConfigItem.m
//  xinghetuoke
//
//  Created by Hepburn on 2021/1/11.
//  Copyright © 2021 Hepburn. All rights reserved.
//

#import "HBUMShareConfigItem.h"

@implementation HBUMShareConfigItem

+ (HBUMShareConfigItem *)createConfigItem:(NSString *)appKey appSecret:(NSString *)appSecret universalLink:(NSString *)universalLink {
    HBUMShareConfigItem *item = [[HBUMShareConfigItem alloc] init];
    item.appKey = appKey;
    item.appSecret = appSecret;
    item.universalLink = universalLink;
    return item;
}

@end
