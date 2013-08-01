//
//  AttributedStringLayout.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AttributedStringLayout.h"

@interface AttributedStringLayout()
{
    NSAttributedString *attributedString;
    CGPathRef path;
    
    CTFramesetterRef framesetter;
    CTFrameRef frame;
}

- (void)layoutInPath;
@end

@implementation AttributedStringLayout
- (void)dealloc
{
    if(framesetter) {
        CFRelease(framesetter);
        framesetter = nil;
    }
    
    self.attributedString = nil;
    self.path = nil;
    
    if(frame) {
        CFRelease(frame);
        frame = nil;
    }
}
#pragma mark -
#pragma mark Properties
- (NSAttributedString *)attributedString
{
    return attributedString;
}

- (void)setAttributedString:(NSAttributedString *)value
{
    if(attributedString != value) {
        if(framesetter) {
            CFRelease(framesetter);
            framesetter = nil;
        }
        
        attributedString = value;
        
        if(attributedString) {
            framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
            [self layoutInPath];
        }
    }
}

- (CGPathRef)path
{
    return path;
}

- (void)setPath:(CGPathRef)value
{
    if(path != value) {
        if(path) {
            CFRelease(path);
        }
        
        path = value;
        
        if(path) {
            CFRetain(path);
            [self layoutInPath];
        }
    }
}

#pragma mark -
#pragma mark Public API
- (CGSize)textSizeWithinSize:(CGSize)size
{
    CFRange fitRange;
    return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, size, &fitRange);
}

- (void)drawInContext:(CGContextRef)context
{
    CTFrameDraw(frame, context);
}

- (NSArray *)CGRectValuesEnclosingStringRange:(CFRange)range
{
    if(!frame) {
        return nil;
    }
    
    NSMutableArray *rects = [[NSMutableArray alloc] init];
    
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint origins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    for(NSUInteger i=0; i<CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange lineRange = CTLineGetStringRange(line);
        
        NSRange intersection = NSIntersectionRange(NSMakeRange(range.location, range.length), NSMakeRange(lineRange.location, lineRange.length));
        if(intersection.length == 0) {
            continue;
        }
        
        CGFloat ascent = 0;
        CGFloat descent = origins[i].y;
        CTLineGetTypographicBounds(line, &ascent, &descent, 0);
        
        CGFloat left = CTLineGetOffsetForStringIndex(line, intersection.location, nil) + origins[i].x;
        CGFloat right = 0;
        CGFloat top = origins[i].y;
        CGFloat bottom = origins[i].y + ascent + descent;
        CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, &right);
        
        CGRect rect = CGRectMake(left, top - descent, right - left, bottom - top);
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }
    
    return rects;
}

#pragma mark -
#pragma mark Private API
- (void)layoutInPath
{
    if(frame) {
        CFRelease(frame);
        frame = nil;
    }
    
    if(self.attributedString == nil || self.path == nil) {
        return;
    }
    
    frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attributedString.length), self.path, nil);
}
@end
