//
//  UIViewController+TabBarItem.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UIViewController+TabBarItem.h"
#import <objc/runtime.h>

static uint32_t TabBarItemKey = 1337;

@implementation UIViewController (TabBarItem)
- (TabBarItem *)adnTabBarItem
{
    if(!objc_getAssociatedObject(self, &TabBarItemKey)) {
        objc_setAssociatedObject(self, &TabBarItemKey, [[TabBarItem alloc] init], OBJC_ASSOCIATION_RETAIN);
    }
    
    return objc_getAssociatedObject(self, &TabBarItemKey);
}
@end
