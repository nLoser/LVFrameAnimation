//
//  MTFrameAnimationCacheManager.h
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MTFrameAnimationImage.h"

@interface MTFrameAnimationCacheManager: NSObject

+ (instancetype)shareManager;

- (NSArray<MTFrameAnimationImage *> *)getAnimationsWithPrefixName:(NSString *)prefixName
                                                       totalCount:(NSUInteger)totalCount;

@end
