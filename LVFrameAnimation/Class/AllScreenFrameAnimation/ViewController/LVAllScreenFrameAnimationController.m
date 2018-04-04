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
    __weak typeof(self) weakSelf = self;
    [_frameAnimationCache getAnimationsWithPrefixName:@"image" totalCount:96 completion:^(NSArray<MTFrameAnimationImage *> *animations) {
        weakSelf.giftAnimationImageView.animationImages = animations;
        [weakSelf.giftAnimationImageView startAnimating];
    }];
}

@end
