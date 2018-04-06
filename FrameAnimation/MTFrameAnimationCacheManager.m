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

@interface MTFrameAnimationCacheManager()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *cacheListResult;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *localCacheResult;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) MTFrameAnimationDataBase *dataBase;
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
        [_cacheListResult setValuesForKeysWithDictionary:[_dataBase db_getCacheListResult]];
    }
    return self;
}

#pragma mark - Public

- (void)getAnimationsWithPrefixName:(NSString *)prefixName
                         totalCount:(NSUInteger)totalCount
                         completion:(completion)completion{
    BOOL dbCacheResult = [[_cacheListResult objectForKey:prefixName] intValue] == 1 ? YES : NO;
    BOOL localCacheResult = [[_localCacheResult objectForKey:prefixName] intValue] == 1 ? YES : NO;
    
    NSMutableArray<MTFrameAnimationImage *> *animationArr = [NSMutableArray array];
    @autoreleasepool {
        if (dbCacheResult && !localCacheResult) {
            NSArray *dbResources = [_dataBase db_getSourcesWithPrefixName:prefixName];
            if (dbResources) {
                [animationArr addObjectsFromArray:dbResources];
                [dbResources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                    [self cacheObject:obj forkey:[NSString stringWithFormat:@"%@_%d",prefixName, (int)idx+1]];
                }];
            }
            [_localCacheResult setValue:@(1) forKey:prefixName];
        }else {
            __block NSMutableDictionary *sortSources = [NSMutableDictionary dictionaryWithCapacity:totalCount];
            for (int i = 1; i <= totalCount; i ++) {
                __weak typeof(self) weakSelf = self;
                __block MTFrameAnimationImage *tempImage = nil;
                
                dispatch_async(YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated), ^{
                    
                    NSString *imageName = [NSString stringWithFormat:@"%@_%d.png",prefixName,i];
                    NSURL *imageFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
                    tempImage = [self getKeyFrameDataRef:imageFileURL
                                              prefixName:imageName index:i
                                           dbCacheResult:dbCacheResult];
                    if(tempImage) {
                        [sortSources setValue:tempImage forKey:[NSString stringWithFormat:@"%d",i]];
                    };
                    if(i == totalCount) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!dbCacheResult) {
                                [weakSelf.dataBase db_insertSourcesWithPrefixName:prefixName sources:animationArr];
                                [weakSelf.cacheListResult removeAllObjects];
                                [weakSelf.cacheListResult setValuesForKeysWithDictionary:[weakSelf.dataBase db_getCacheListResult]];
                            }
                            if (completion) {
                                NSMutableArray *allKeys = [NSMutableArray arrayWithArray:sortSources.allKeys];
                                [allKeys sortUsingComparator: ^NSComparisonResult (NSString *key1, NSString *key2) {
                                    return [@(key1.intValue) compare:@(key2.intValue)];
                                }];
                                for(id key in allKeys) {
                                    id object = [sortSources objectForKey:key];
                                    [animationArr addObject:object];
                                }
                                completion(animationArr);
                            }
                        });
                    }
                });
            }
        }
    }
}

- (MTFrameAnimationImage *)getKeyFrameDataRef:(NSURL *)url
                                   prefixName:(NSString *)prefixName
                                        index:(int)index
                                dbCacheResult:(BOOL)dbCacheResult{
    if(!url) return nil;
    MTFrameAnimationImage *data = [self cacheObjectForkey:[NSString stringWithFormat:@"%@_%d",prefixName, index]];
    if (!data) {
        if (dbCacheResult) {
            data = [_dataBase db_getSourceWithPrefixName:prefixName index:index];
            if (data) return data;
        }
        NSDictionary *imageOptions = @{(__bridge id)kCGImageSourceShouldCache:@YES,
                                        (__bridge id)kCGImageSourceShouldCacheImmediately:@YES};
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        if(!sourceRef) return nil;
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)imageOptions);
        data = (MTFrameAnimationImage *)[UIImage imageWithCGImage:YYCGImageCreateDecoded(imageRef)];
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

#pragma mark - Private - Decode Image

//http://www.cocoachina.com/ios/20170227/18784.html
CGImageRef YYCGImageCreateDecoded(CGImageRef imageRef) {
    if(!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if(width == 0 || height == 0) return NULL;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    // BGRA8888 (premultiplied) or BGRX8888
    // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, YYCGColorSpaceGetDeviceRGB(), bitmapInfo);
    if (!context) return NULL;
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    return newImage;
}

CGColorSpaceRef YYCGColorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

@end
