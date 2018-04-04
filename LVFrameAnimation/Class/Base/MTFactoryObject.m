//
//  MTFactoryObject.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "MTFactoryObject.h"

@implementation MTFactoryObject

@end


@interface MTFactoryClassObject()
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) id obj;
@end
@implementation MTFactoryClassObject
+ (instancetype)createObjectWithName:(NSString *)title object:(id)object {
    MTFactoryClassObject *obj = [MTFactoryClassObject new];
    obj.title = title;
    obj.obj = object;
    return obj;
}
@end
