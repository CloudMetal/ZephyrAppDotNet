//
//  AvatarImageView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AvatarImageView.h"


@implementation AvatarImageView
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        [self addObserver:self forKeyPath:@"image" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"image"]) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image = nil;
    if(self.image) {
        image = self.image;
    } else {
        image = [UIImage imageNamed:@"avatar-placeholder.png"];
    }
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 1, 81, 81) cornerRadius:2] addClip];
    [image drawInRect:CGRectMake(1, 1, 81, 81)];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    
    [[UIImage imageNamed:@"profile-avatar-overlay.png"] drawInRect:self.bounds];
}
@end
