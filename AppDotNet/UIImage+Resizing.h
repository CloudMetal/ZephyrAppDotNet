//
//  UIImage+Resizing.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resizing)
- (UIImage *)fittedImageInSize:(CGSize)size;
- (UIImage *)scaledImageToPixelCount:(NSUInteger)pixelCount;

- (UIImage *)roundedImageByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
@end
