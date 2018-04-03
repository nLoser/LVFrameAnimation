//
//  MTFrameAnimationCacheManager.h
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTFrameAnimationCacheManager: NSObject

+ (instancetype)shareManager;

- (UIImage *)getKeyFrameDataRef:(NSURL *)url key:(NSString *)key;

@end
