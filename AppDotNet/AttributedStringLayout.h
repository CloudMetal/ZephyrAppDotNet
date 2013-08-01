//
//  AttributedStringLayout.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface AttributedStringLayout : NSObject
@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic) CGPathRef path;

- (CGSize)textSizeWithinSize:(CGSize)size;
- (void)drawInContext:(CGContextRef)context;
- (NSArray *)CGRectValuesEnclosingStringRange:(CFRange)range;
@end
