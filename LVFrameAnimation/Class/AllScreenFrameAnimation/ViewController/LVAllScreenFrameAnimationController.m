//
//  LVAllScreenFrameAnimationController.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "LVAllScreenFrameAnimationController.h"

#import "MTFrameAnimationCacheManager.h"
#import "MTFrameAnimationImageView.h"

@interface LVAllScreenFrameAnimationController ()
@property (nonatomic, weak) MTFrameAnimationCacheManager *frameAnimationCache;
@property (nonatomic, strong) UIImageView *giftAnimationImageView;
@end

@implementation LVAllScreenFrameAnimationController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.giftAnimationImageView];
    
    _frameAnimationCache = [MTFrameAnimationCacheManager shareManager];
}

#pragma mark - Custom Accessors

- (UIImageView *)giftAnimationImageView {
    if (!_giftAnimationImageView) {
        _giftAnimationImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _giftAnimationImageView.backgroundColor = [UIColor lightGrayColor];
        _giftAnimationImageView.userInteractionEnabled = NO;
    }
    return _giftAnimationImageView;
}

#pragma mark - UIEvents

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_giftAnimationImageView stopAnimating];
    NSMutableArray *animationArr = [NSMutableArray array];
    @autoreleasepool{
        for (int i = 1; i <= 96; i ++) {
            NSString *imageName = [NSString stringWithFormat:@"image_%d.png",i];
            NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
            NSURL *imageFileURL = [NSURL fileURLWithPath:imageFilePath];
            UIImage *tempImage = [_frameAnimationCache getKeyFrameDataRef:imageFileURL key:imageName];
            if(!tempImage) continue;
            [animationArr addObject:tempImage];
        }
    }
    _giftAnimationImageView.animationImages = animationArr;
    [_giftAnimationImageView startAnimating];
}

@end
