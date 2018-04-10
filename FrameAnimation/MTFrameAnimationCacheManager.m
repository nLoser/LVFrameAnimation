//
//  MTFrameAnimationCacheManager.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "MTFrameAnimationCacheManager.h"

#import "YYDispatchQueuePool.h"

#import "MTFrameAnimationDataBase.h"

#import "UIImage+Util.h"

@interface MTFrameAnimationCacheManager()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *cacheListResult;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *localCacheResult;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) MTFrameAnimationDataBase *dataBase;
@property (nonatomic, assign, readwrite) kMTFrameAnimationCacheManagerStatus status;
@property (nonatomic, strong) NSMutableDictionary *tempKeyFrameImageSortSources;
@end

@implementation MTFrameAnimationCacheManager

#pragma mark - LifeCycle

+ (instancetype)shareManager {
    static MTFrameAnimationCacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MTFrameAnimationCacheManager alloc] initWithDomain:@"defaultCache"];
    });
    return manager;
}

- (instancetype)initWithDomain:(NSString *)domain {
    if (self = [super init]) {
        _cache = [[NSCache alloc] init];
        _cache.name = [NSString stringWithFormat:@"com.meipai.MTFrameAnimationCacheManager.%@",domain];
        _cache.countLimit = 0;
        
        _dataBase = [[MTFrameAnimationDataBase alloc] init];
        
        _cacheListResult = [NSMutableDictionary dictionary];
        _localCacheResult = [NSMutableDictionary dictionary];
        _tempKeyFrameImageSortSources = [NSMutableDictionary dictionary];
        [_cacheListResult setValuesForKeysWithDictionary:[_dataBase loadCacheListResult]];
        
        _status = kMTFrameAnimationCacheManagerStatusIdle;
    }
    return self;
}

#pragma mark - Public

- (void)loadFrameAnimationsWithPrefixName:(NSString *)prefixName
                               totalCount:(NSUInteger)totalCount
                               completion:(completion)completion {
    if (_status == kMTFrameAnimationCacheManagerStatusLoading) return;
    _status = kMTFrameAnimationCacheManagerStatusLoading;
    
    BOOL dbCacheResult = [[_cacheListResult objectForKey:prefixName] intValue] == 1 ? YES : NO;
    BOOL localCacheResult = [[_localCacheResult objectForKey:prefixName] intValue] == 1 ? YES : NO;
    
    NSMutableArray<MTFrameAnimationImage *> *animationArr = [NSMutableArray array];
    @autoreleasepool {
        if (dbCacheResult) {
            if (localCacheResult) {
                @autoreleasepool{
                    for (int i = 1; i <= totalCount; i++) {
                        UIImage *img = (__bridge UIImage *)(loadKeyFrameImageData(prefixName, i, YES, self));
                        if (img) {
                            [animationArr addObject:(id)img];
                        }
                    }
                }
            }else {
                NSArray<MTFrameAnimationImage *> *dbResources = [_dataBase loadFrameSourcesWithPrefixName:prefixName];
                if (dbResources) {
                    [animationArr addObjectsFromArray:dbResources];
                    [dbResources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                        [self cacheObject:obj forkey:[NSString stringWithFormat:@"%@_%d",prefixName, (int)idx+1]];
                    }];
                }
                [_localCacheResult setValue:@(1) forKey:prefixName];
            }
            self.status = kMTFrameAnimationCacheManagerStatusIdle;
            completion(animationArr);
        }else {
            [_tempKeyFrameImageSortSources removeAllObjects];
            
            for (int i = 1; i <= totalCount; i ++) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated), ^{
                    __block MTFrameAnimationImage *tempImage = nil;
                    tempImage = (id)[UIImage imageWithCGImage:loadKeyFrameImageData(prefixName, i, dbCacheResult, self)];
                    if(tempImage) {
                        [weakSelf.tempKeyFrameImageSortSources setValue:tempImage forKey:[NSString stringWithFormat:@"%d",i]];
                    };
                    if(i == totalCount) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                NSMutableArray *allKeys = [NSMutableArray arrayWithArray:weakSelf.tempKeyFrameImageSortSources.allKeys];
                                [allKeys sortUsingComparator: ^NSComparisonResult (NSString *key1, NSString *key2) {
                                    return [@(key1.intValue) compare:@(key2.intValue)];
                                }];
                                for(id key in allKeys) {
                                    id object = [weakSelf.tempKeyFrameImageSortSources objectForKey:key];
                                    [animationArr addObject:object];
                                }
                                
                                if (!dbCacheResult) {
                                    [weakSelf.dataBase insertFrameSourcesWithPrefixName:prefixName sources:animationArr];
                                    [weakSelf.cacheListResult removeAllObjects];
                                    [weakSelf.cacheListResult setValuesForKeysWithDictionary:[weakSelf.dataBase loadCacheListResult]];
                                }
                                
                                weakSelf.status = kMTFrameAnimationCacheManagerStatusIdle;
                                completion(animationArr);
                            }
                        });
                    }
                });
            }
        }
    }
    completion(animationArr);
}

- (void)loadFrameAnimationWithPrefixName:(NSString *)prefixName
                                   range:(NSRange *)range
                              completion:(completion)completion {
    if (_status == kMTFrameAnimationCacheManagerStatusLoading) return;
    _status = kMTFrameAnimationCacheManagerStatusLoading;
    
}

#pragma mark - Private

- (id)cacheObjectForkey:(NSString *)key {
    return [_cache objectForKey:key];
}

- (void)cacheObject:(id)obj forkey:(NSString *)key {
    [_cache setObject:obj forKey:key];
}

#pragma mark - Private - Decode Image

static CGImageRef loadKeyFrameImageData(NSString * prefixName, int index, BOOL dbCacheResult, MTFrameAnimationCacheManager * this) {
    CGImageRef data = (__bridge CGImageRef)([this cacheObjectForkey:[NSString stringWithFormat:@"%@_%d",prefixName, index]]);
    if (data == NULL) {
        if (dbCacheResult) {
            data = [this->_dataBase loadFrameWithPrefixName:prefixName index:index].CGImage;
            if (data) return data;
        }
        NSString *sourceName = [NSString stringWithFormat:@"%@_%d.png",prefixName, index];
        NSURL * url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:sourceName ofType:nil]];
        NSDictionary *imageOptions = @{(__bridge id)kCGImageSourceShouldCache:@YES,
                                       (__bridge id)kCGImageSourceShouldCacheImmediately:@YES};
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        if(!sourceRef) return nil;
        
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)imageOptions);
        data = YYCGImageCreateDecoded(imageRef);
        [this cacheObject:(__bridge id)(data) forkey:[NSString stringWithFormat:@"%@_%d",prefixName, index]];
        
        CFRelease(imageRef);
    }
    return data;
}

@end
