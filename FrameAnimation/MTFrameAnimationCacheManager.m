//
//  MTFrameAnimationCacheManager.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "MTFrameAnimationCacheManager.h"
#import "MTFrameAnimationDataBase.h"

@interface MTFrameAnimationCacheManager()
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) MTFrameAnimationDataBase *dataBase;
@end

@implementation MTFrameAnimationCacheManager

#pragma mark - LifeCycle

+ (instancetype)shareManager {
    static MTFrameAnimationCacheManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MTFrameAnimationCacheManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _cache = [[NSCache alloc] init];
        _cache.name = @"com.meipai.MTFrameAnimationCacheManager.cache";
        _cache.countLimit = 0;
        
        _dataBase = [[MTFrameAnimationDataBase alloc] init];
    }
    return self;
}

#pragma mark - Public

- (NSArray<MTFrameAnimationImage *> *)getAnimationsWithPrefixName:(NSString *)prefixName
                                                       totalCount:(NSUInteger)totalCount {
    NSArray * result = [_dataBase db_getSourcesWithPrefixName:prefixName];
    if (result) return result;
    
    NSMutableArray<MTFrameAnimationImage *> *animationArr = [NSMutableArray array];
    @autoreleasepool{
        for (int i = 1; i <= totalCount; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"%@_%d.png",prefixName,i];
            NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
            NSURL *imageFileURL = [NSURL fileURLWithPath:imageFilePath];
            MTFrameAnimationImage *tempImage = [self getKeyFrameDataRef:imageFileURL key:imageName];
            if(!tempImage) continue;
            [animationArr addObject:tempImage];
        }
    }
    [_dataBase db_insertSourcesWithPrefixName:prefixName sources:animationArr];
    return animationArr;
}

- (MTFrameAnimationImage *)getKeyFrameDataRef:(NSURL *)url key:(NSString *)key {
    if(!url) return nil;
    MTFrameAnimationImage * data = [self cacheObjectForkey:key];
    if (!data) {
        NSDictionary * imageOptions = @{(__bridge id)kCGImageSourceShouldCache:@YES,
                                        (__bridge id)kCGImageSourceShouldCacheImmediately:@YES};
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        if(!sourceRef) return nil;
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0,
                                                              (__bridge CFDictionaryRef)imageOptions);
        data = (MTFrameAnimationImage *)[UIImage imageWithCGImage:imageRef];
        [self cacheObject:data forkey:key];
        CFRelease(imageRef);
    }
    return data;
}

#pragma mark - Private

- (id)cacheObjectForkey:(NSString *)key {
    return [_cache objectForKey:key];
}

- (void)cacheObject:(id)obj forkey:(NSString *)key {
    [_cache setObject:obj forKey:key];
}

@end
