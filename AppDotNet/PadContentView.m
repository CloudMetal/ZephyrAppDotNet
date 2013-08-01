//
//  PadContentView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PadContentView.h"

@interface PadContentView()
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) PostStreamPassThroughView *passThroughView;

- (void)finishInit;
@end

@implementation PadContentView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (void)finishInit
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.hidden = YES;
        return;
    }
    
    self.clipsToBounds = YES;
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.image = [[UIImage imageNamed:@"profile-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(32, 32, 32, 32)];
    [self addSubview:self.backgroundView];
    
    self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, self.bounds.size.height)];
    self.leftImageView.image = [[UIImage imageNamed:@"ipad-ls-bg-border-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(38, 5, 5, 5)];
    [self addSubview:self.leftImageView];
    
    self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, self.bounds.size.height)];
    self.rightImageView.image = [[UIImage imageNamed:@"ipad-ls-bg-border-right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(38, 5, 5, 5)];
    [self addSubview:self.rightImageView];
    
    self.passThroughView = [[PostStreamPassThroughView alloc] initWithFrame:self.bounds];
    self.passThroughView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.passThroughView];
    
    [self addObserver:self forKeyPath:@"passThroughViewTarget" options:0 context:0];
    [self addObserver:self forKeyPath:@"backgroundStyle" options:0 context:0];
}

- (void)dealloc
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return;
    }
    [self removeObserver:self forKeyPath:@"passThroughViewTarget"];
    [self removeObserver:self forKeyPath:@"backgroundStyle"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"passThroughViewTarget"]) {
        self.passThroughView.passthroughView = self.passThroughViewTarget;
    } else if([keyPath isEqualToString:@"backgroundStyle"]) {
        if(self.backgroundStyle == PadContentViewBackgroundStyleDefault) {
            self.backgroundView.image = [[UIImage imageNamed:@"profile-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(32, 32, 32, 32)];
        } else if(self.backgroundStyle == PadContentViewBackgroundStyleDark) {
            self.backgroundView.image = [[UIImage imageNamed:@"post-stream-dark-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(32, 32, 32, 32)];
        }
    }
}

- (void)layoutSubviews
{
    CGFloat contentWidth = 704;
    CGFloat contentLeft = roundf((self.bounds.size.width - contentWidth) * 0.5);
    self.leftImageView.frame = CGRectMake(contentLeft - 83, 0, 83, self.bounds.size.height);
    self.rightImageView.frame = CGRectMake(contentLeft + contentWidth, 0, 83, self.bounds.size.height);
}
@end
