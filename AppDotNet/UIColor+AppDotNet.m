//
//  UIColor+AppDotNet.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UIColor+AppDotNet.h"

@implementation UIColor (AppDotNet)
+ (UIColor *)postBackgroundColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:241.0 / 255.0 green:241.0 / 255.0 blue:241.0 / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postHighlightedBackgroundColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:(241.0 * 0.95) / 255.0 green:(241.0 * 0.95) / 255.0 blue:(241.0 * 0.95) / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postHighlightedTopStrokeColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:0.88 green:0.93 blue:0.98 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postTopStrokeColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor whiteColor];
    }
    return color;
}

+ (UIColor *)postBottomStrokeColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:193.0 / 255.0 green:193.0 / 255.0 blue:193.0 / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postHighlightedBottomStrokeColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:0.63 green:0.67 blue:0.7 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postHighlightedMetaTextColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:0.55 green:0.65 blue:0.75 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postMetaTextColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:179.0 / 255.0 green:179.0 / 255.0 blue:179.0 / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postUserNameColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:69.0 / 255.0 green:69.0 / 255.0 blue:69.0 / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postBodyTextColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:81.0 / 255.0 green:81.0 / 255.0 blue:81.0 / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postLinkTextColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor colorWithRed:62.0 / 255.0 green:122.0 / 255.0 blue:162.0 / 255.0 alpha:1.0];
    }
    return color;
}

+ (UIColor *)postShadowTextColor
{
    static UIColor *color = nil;
    if(!color) {
        color = [UIColor whiteColor];
    }
    return color;
}
@end
