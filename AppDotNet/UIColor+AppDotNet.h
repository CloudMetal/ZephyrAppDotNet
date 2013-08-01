//
//  UIColor+AppDotNet.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <UIKit/UIKit.h>

@interface UIColor (AppDotNet)
+ (UIColor *)postBackgroundColor;
+ (UIColor *)postHighlightedBackgroundColor;
+ (UIColor *)postHighlightedTopStrokeColor;
+ (UIColor *)postTopStrokeColor;
+ (UIColor *)postBottomStrokeColor;
+ (UIColor *)postHighlightedBottomStrokeColor;
+ (UIColor *)postHighlightedMetaTextColor;
+ (UIColor *)postMetaTextColor;
+ (UIColor *)postUserNameColor;
+ (UIColor *)postBodyTextColor;
+ (UIColor *)postLinkTextColor;
+ (UIColor *)postShadowTextColor;
@end
