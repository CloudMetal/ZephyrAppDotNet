//
//  UIImage+Resizing.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UIImage+Resizing.h"

@implementation UIImage (Resizing)
- (UIImage *)fittedImageInSize:(CGSize)size
{
    if(self.size.width <= size.width && self.size.height <= size.height) {
        return self;
    }
    
    CGFloat widthScalar = size.width / self.size.width;
    CGFloat heightScalar = size.height / self.size.height;
    
    CGSize newSize = CGSizeMake(roundf(self.size.width * widthScalar), roundf(self.size.height * widthScalar));
    
    if(newSize.width > size.width || newSize.height > size.height) {
        newSize = CGSizeMake(roundf(self.size.width * heightScalar), roundf(self.size.height * heightScalar));
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

- (UIImage *)scaledImageToPixelCount:(NSUInteger)pixelCount
{
    if(self.size.width * self.size.height <= pixelCount) {
        return self;
    }
    
    CGFloat scalar = sqrtf(pixelCount / (self.size.width * self.size.height));
    
    CGSize newSize = CGSizeMake(roundf(scalar * self.size.width), roundf(scalar * self.size.height));
    
    UIGraphicsBeginImageContext(newSize);
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

- (UIImage *)roundedImageByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.size.width, self.size.height) byRoundingCorners:corners cornerRadii:cornerRadii] addClip];
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}
@end
