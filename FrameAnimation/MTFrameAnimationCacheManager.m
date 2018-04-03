//
//  MTFrameAnimationCacheManager.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "MTFrameAnimationCacheManager.h"

@implementation MTFrameAnimationCacheManager

- (CFDataRef)getKeyFrameDataRef:(NSURL *)url {
    if(!url) return nil;
    NSDictionary * imageOptions = @{(__bridge id)kCGImageSourceShouldCache:@YES,
                                    (__bridge id)kCGImageSourceShouldCacheImmediately:@YES};
    CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)imageOptions);
    CGDataProviderRef providerRef = CGImageGetDataProvider(imageRef);
    CFDataRef dataRef = CGDataProviderCopyData(providerRef);
    return dataRef;
}

@end
