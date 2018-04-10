//
//  MTFrameAnimationDataBase.h
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/4.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTFrameAnimationImage.h"

@interface MTFrameAnimationDataBase : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 数据库返回帧图片加载
 @param prefixName 帧动画前缀名，规定XXXX_number.png，XXXX为前缀
 @return 提前加载图片帧
 */
- (NSArray<MTFrameAnimationImage *> *)loadFrameSourcesWithPrefixName:(NSString *)prefixName;


/**
 数据库返回图片加载
 @param prefixName 帧动画前缀名，规定XXXX_number.png，XXXX为前缀
 @param index 帧动画的索引，规定XXXX_number.png，number为索引
 @return 提前加载图片
 */
- (MTFrameAnimationImage *)loadFrameWithPrefixName:(NSString *)prefixName index:(int)index;


/**
 图片信息插入数据库

 @param prefixName 帧动画前缀名，规定XXXX_number.png，XXXX为前缀
 @param sources 帧动画加载信息
 */
- (void)insertFrameSourcesWithPrefixName:(NSString *)prefixName
                                 sources:(NSArray<MTFrameAnimationImage *> *)sources;


/**
 数据库已经插入的帧动画列表
 */
- (NSDictionary<NSString *, NSNumber *> *)db_getCacheListResult;

@end
