//
//  LabeledDividerView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "LabeledDividerView.h"

@implementation LabeledDividerView
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        [self addObserver:self forKeyPath:@"text" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"text"]) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    // 11
    
    CGFloat halfHeight = roundf(self.bounds.size.height * 0.5);
    
    if(self.text != nil) {
        UIFont *font = [UIFont boldSystemFontOfSize:11];
        
        CGSize size = [self.text sizeWithFont:font];
        
        [[UIColor blackColor] set];
        [self.text drawInRect:CGRectMake(0, 1, self.bounds.size.width, self.bounds.size.height) withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentCenter];
        
        [[UIColor colorWithRed:129.0 / 255.0 green:181.0 / 255.0 blue:212.0 / 255.0 alpha:1.0] set];
        [self.text drawInRect:self.bounds withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentCenter];
        
        CGFloat textWidth = size.width + 10;
        CGFloat dividerWidth = roundf((self.bounds.size.width - textWidth) * 0.5);
        
        [[UIColor colorWithWhite:0 alpha:0.7] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, halfHeight - 1, dividerWidth, 1)] fill];
        
        [[UIColor colorWithWhite:1 alpha:0.1] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, halfHeight, dividerWidth, 1)] fill];
        
        [[UIColor colorWithWhite:0 alpha:0.7] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.size.width - dividerWidth, halfHeight - 1, dividerWidth, 1)] fill];
        
        [[UIColor colorWithWhite:1 alpha:0.1] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.size.width - dividerWidth, halfHeight, dividerWidth, 1)] fill];
    } else {
        [[UIColor colorWithWhite:0 alpha:0.7] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, halfHeight - 1, self.bounds.size.width, 1)] fill];
        
        [[UIColor colorWithWhite:1 alpha:0.1] set];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, halfHeight, self.bounds.size.width, 1)] fill];
    }
}
@end
