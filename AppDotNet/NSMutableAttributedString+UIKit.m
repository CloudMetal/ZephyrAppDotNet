//
//  NSAttributedString+UIKit.m
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "NSMutableAttributedString+UIKit.h"
#import <CoreText/CoreText.h>

@implementation NSMutableAttributedString (UIKit)
- (void)addFontAttribute:(UIFont *)font range:(NSRange)range
{
    if(range.location == self.length) {
        return;
    }
    
    if(range.location + range.length > self.length) {
        range.length = self.length - range.location;
    }
    
    CFMutableAttributedStringRef cfSelf = (__bridge CFMutableAttributedStringRef)self;
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
    
    CFAttributedStringSetAttribute(cfSelf, CFRangeMake(range.location, range.length), kCTFontAttributeName, ctFont);
    
    CFRelease(ctFont);
}

- (void)addColorAttribute:(UIColor *)color range:(NSRange)range
{
    if(range.location == self.length) {
        return;
    }
    
    if(range.location + range.length > self.length) {
        range.length = self.length - range.location;
    }
    
    CFMutableAttributedStringRef cfSelf = (__bridge CFMutableAttributedStringRef)self;
    CFAttributedStringSetAttribute(cfSelf, CFRangeMake(range.location, range.length), kCTForegroundColorAttributeName, color.CGColor);
}
@end
