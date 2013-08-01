//
//  UIApplication+Sandbox.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UIApplication+Sandbox.h"

@implementation UIApplication (Sandbox)
- (BOOL)isSandboxed
{
#ifdef IS_PRODUCTION
    return NO;
#else
    return YES;
#endif
}
@end
