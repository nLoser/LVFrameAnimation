//
//  MTFrameAnimationDataBase.h
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/4.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTFrameAnimationImage.h"

@interface MTFrameAnimationDataBase : NSObject

- (NSArray<MTFrameAnimationImage *> *)db_getSourcesWithPrefixName:(NSString *)prefixName;

- (void)db_insertSourcesWithPrefixName:(NSString *)prefixName
                               sources:(NSArray<MTFrameAnimationImage *> *)sources;

@end
