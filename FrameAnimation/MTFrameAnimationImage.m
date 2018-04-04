//
//  MTFrameAnimationImage.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/4.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "MTFrameAnimationImage.h"

@interface MTFrameAnimationImage()<NSDiscardableContent>

@end

@implementation MTFrameAnimationImage

- (BOOL)beginContentAccess {
    NSLog(@"加入");
    return _isUsing;
}

//- (void)endContentAccess;
//- (void)discardContentIfPossible;
- (BOOL)isContentDiscarded {
    NSLog(@"删除");
    return !_isUsing;
}

@end
