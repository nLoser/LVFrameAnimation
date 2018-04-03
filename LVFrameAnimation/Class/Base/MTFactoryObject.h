//
//  MTFactoryObject.h
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTFactoryObject : NSObject

@end

@interface MTFactoryClassObject : NSObject
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) id obj;
+ (instancetype)createObjectWithName:(NSString *)title object:(id)object;
@end
