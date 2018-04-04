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

typedef void (^completion) (NSArray<MTFrameAnimationImage *> *);

@interface MTFrameAnimationCacheManager: NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

+ (instancetype)shareManager;

- (void)getAnimationsWithPrefixName:(NSString *)prefixName
                         totalCount:(NSUInteger)totalCount
                         completion:(completion)completion;

@end
