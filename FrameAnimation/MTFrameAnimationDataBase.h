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

- (NSArray<MTFrameAnimationImage *> *)db_getSourcesWithPrefixName:(NSString *)prefixName;

- (MTFrameAnimationImage *)db_getSourceWithPrefixName:(NSString *)prefixName
                                                index:(int)index;

- (void)db_insertSourcesWithPrefixName:(NSString *)prefixName
                               sources:(NSArray<MTFrameAnimationImage *> *)sources;

- (NSDictionary<NSString *, NSNumber *> *)db_getCacheListResult;

@end
