//
//  AccountPickerButton.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AccountPickerButton.h"

@interface AccountPickerButton()
@end

@implementation AccountPickerButton
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIImage *backgroundImage = nil;
    if(self.highlighted) {
        backgroundImage = [[UIImage imageNamed:@"nav-bar-item-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
    } else {
        backgroundImage = [[UIImage imageNamed:@"nav-bar-item.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
    }
    
    CGRect backgroundRect = CGRectMake(0, floorf((self.bounds.size.height - 30)) * 0.5, 29, 30);
    [backgroundImage drawInRect: backgroundRect];
    
    CGRect imageRect = CGRectMake(backgroundRect.origin.x + 2, backgroundRect.origin.y + 2, backgroundRect.size.width - 4, backgroundRect.size.width - 4);
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:3] addClip];
    [self.image drawInRect:imageRect];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}
@end
