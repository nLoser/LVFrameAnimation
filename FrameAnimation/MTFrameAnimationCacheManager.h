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

typedef NS_ENUM(NSUInteger, kMTFrameAnimationCacheManagerStatus) {
    kMTFrameAnimationCacheManagerStatusIdle,    ///< 加载闲置
    kMTFrameAnimationCacheManagerStatusLoading  ///< 正在加载中
};

@interface MTFrameAnimationCacheManager: NSObject

/**
 任务状态
 */
@property (nonatomic, assign, readonly) kMTFrameAnimationCacheManagerStatus status;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 返回 MTFrameAnimationCacheManager 分享对象
 */
+ (instancetype)shareManager;

/**
 获取制定前缀的帧动画加载资源
 @param prefixName 帧动画前缀名，规定XXXX_number.png，XXXX为前缀
 @param totalCount 帧动画资源的帧数
 @param completion block返回加载完成的帧动画资源
 */
- (void)loadFrameAnimationsWithPrefixName:(NSString *)prefixName
                               totalCount:(NSUInteger)totalCount
                               completion:(completion)completion;



@end
