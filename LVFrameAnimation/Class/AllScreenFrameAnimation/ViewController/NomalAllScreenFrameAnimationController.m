//
//  NomalAllScreenFrameAnimationController.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "NomalAllScreenFrameAnimationController.h"


@interface NomalAllScreenFrameAnimationController ()
@property (nonatomic, strong) UIImageView *giftAnimationImageView;
@end

@implementation NomalAllScreenFrameAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.giftAnimationImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_giftAnimationImageView stopAnimating];
    _giftAnimationImageView.animationImages = nil;
}

#pragma mark -

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_giftAnimationImageView stopAnimating];
    NSMutableArray *animationsArr = [NSMutableArray array];
    @autoreleasepool{
        for (int i = 1; i <= 96; i ++) {
            UIImage * tempArray = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"image_%d.png",i] ofType:nil]];
            if (!tempArray) continue;
            [animationsArr addObject:tempArray];
        }
    }
    _giftAnimationImageView.animationImages = animationsArr;
    [_giftAnimationImageView startAnimating];
}

#pragma mark - Getter

- (UIImageView *)giftAnimationImageView {
    if (!_giftAnimationImageView) {
        _giftAnimationImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _giftAnimationImageView.backgroundColor = [UIColor lightGrayColor];
        _giftAnimationImageView.userInteractionEnabled = NO;
    }
    return _giftAnimationImageView;
}

@end
