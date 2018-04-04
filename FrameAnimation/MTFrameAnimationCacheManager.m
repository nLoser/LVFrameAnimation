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
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *cacheListResult;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *localCacheResult;
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
        
        [_cacheListResult setValuesForKeysWithDictionary:[_dataBase db_getCacheListResult]];
        _localCacheResult = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public

- (NSArray<MTFrameAnimationImage *> *)getAnimationsWithPrefixName:(NSString *)prefixName
                                                       totalCount:(NSUInteger)totalCount {
    BOOL dbCacheResult = [[_cacheListResult objectForKey:prefixName] intValue] == 1 ? YES : NO;
    BOOL localCacheResult = [[_localCacheResult objectForKey:prefixName] intValue] == 1 ? YES : NO;
    
    NSMutableArray<MTFrameAnimationImage *> *animationArr = [NSMutableArray array];
    @autoreleasepool{
        if (dbCacheResult && !localCacheResult) {
            NSArray *dbResources = [_dataBase db_getSourcesWithPrefixName:prefixName];
            if (dbResources) {
                [animationArr addObjectsFromArray:dbResources];
                [dbResources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self cacheObject:obj forkey:[NSString stringWithFormat:@"%@_%d",prefixName, (int)idx+1]];
                }];
            }
        }else {
            for (int i = 1; i <= totalCount; i ++) {
                NSString *imageName = [NSString stringWithFormat:@"%@_%d.png",prefixName,i];
                NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
                NSURL *imageFileURL = [NSURL fileURLWithPath:imageFilePath];
                MTFrameAnimationImage *tempImage = [self getKeyFrameDataRef:imageFileURL
                                                                 prefixName:imageName
                                                                      index:i
                                                              dbCacheResult:dbCacheResult];
                if(!tempImage) continue;
                [animationArr addObject:tempImage];
            }
        }
    }
    
    if (!dbCacheResult) {
        [_dataBase db_insertSourcesWithPrefixName:prefixName sources:animationArr];
    }
    return animationArr;
}

- (MTFrameAnimationImage *)getKeyFrameDataRef:(NSURL *)url
                                   prefixName:(NSString *)prefixName
                                        index:(int)index
                                dbCacheResult:(BOOL)dbCacheResult{
    if(!url) return nil;
    MTFrameAnimationImage * data = [self cacheObjectForkey:[NSString stringWithFormat:@"%@_%d",prefixName, index]];
    if (!data) {
        if (dbCacheResult) {
            data = [_dataBase db_getSourceWithPrefixName:prefixName index:index];
            if (data) return data;
        }
        NSDictionary * imageOptions = @{(__bridge id)kCGImageSourceShouldCache:@YES,
                                        (__bridge id)kCGImageSourceShouldCacheImmediately:@YES};
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        if(!sourceRef) return nil;
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0,
                                                              (__bridge CFDictionaryRef)imageOptions);
        data = (MTFrameAnimationImage *)[UIImage imageWithCGImage:imageRef];
        [self cacheObject:data forkey:[NSString stringWithFormat:@"%@_%d",prefixName, index]];
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
