//
//  NewPostCountView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "NewPostCountView.h"

@interface NewPostCountView()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *postCountLabel;
@property (nonatomic, strong) UIButton *scrollToUnreadButton;
@end

@implementation NewPostCountView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundImageView.image = [UIImage imageNamed:@"posts-new-notification.png"];
        [self addSubview:self.backgroundImageView];
        
        self.postCountLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.postCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.postCountLabel.font = [UIFont boldSystemFontOfSize:14];
        self.postCountLabel.textAlignment = UITextAlignmentCenter;
        self.postCountLabel.opaque = NO;
        self.postCountLabel.backgroundColor = [UIColor clearColor];
        self.postCountLabel.textColor = [UIColor postBackgroundColor];
        self.postCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.9];
        self.postCountLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.postCountLabel];
        
        self.postCountLabel.text = @"0 new posts";
        
        self.scrollToUnreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.scrollToUnreadButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.scrollToUnreadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.scrollToUnreadButton addTarget:self action:@selector(scrollToUnread:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.scrollToUnreadButton];
        
        self.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
        
        [self addObserver:self forKeyPath:@"countOfNewPosts" options:0 context:0];
        [self addObserver:self forKeyPath:@"shouldShowScrollToUnreadButton" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"countOfNewPosts"];
    [self removeObserver:self forKeyPath:@"shouldShowScrollToUnreadButton"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"countOfNewPosts"]) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            if(self.countOfNewPosts > 0) {
                self.transform = CGAffineTransformIdentity;
            } else {
                self.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
            }
        } completion:^(BOOL finished) {
            
        }];
        
        if(self.countOfNewPosts == 1) {
            self.postCountLabel.text = @"1 new post";
        } else {
            self.postCountLabel.text = [NSString stringWithFormat:@"%u new posts", self.countOfNewPosts];
        }
    } else if([keyPath isEqualToString:@"shouldShowScrollToUnreadButton"]) {
        self.scrollToUnreadButton.hidden = !self.shouldShowScrollToUnreadButton;
    }
}

- (void)scrollToUnread:(id)sender
{
    [self.delegate newPostCountViewRequestedScrollToUnread:self];
}
@end
