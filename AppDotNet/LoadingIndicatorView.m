//
//  LoadingIndicatorView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "LoadingIndicatorView.h"

@interface LoadingIndicatorView()
@property (nonatomic) BOOL ticking;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readonly) NSArray *loadingImages;
@property (nonatomic, readonly) NSArray *spinnerImages;

- (void)tick;
@end

@implementation LoadingIndicatorView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"l-01.png"]];
        [self addSubview:self.imageView];
        
        [self addObserver:self forKeyPath:@"state" options:0 context:0];
        [self addObserver:self forKeyPath:@"pullToRefreshProgress" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"state"];
    [self removeObserver:self forKeyPath:@"pullToRefreshProgress"];
}

#pragma mark -
#pragma mark Overrides
- (void)layoutSubviews
{
    CGSize imageSize = self.imageView.image.size;
    CGFloat left = roundf((self.bounds.size.width - imageSize.width) * 0.5);
    CGFloat top = roundf((self.bounds.size.height - imageSize.height) * 0.5);
    
    self.imageView.frame = CGRectMake(left, top, imageSize.width, imageSize.height);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"]) {
        if(self.state == LoadingIndicatorViewStateLoading) {
            self.imageView.image = [self.spinnerImages objectAtIndex:0];
            [self tick];
        } else {
            self.ticking = NO;
            self.imageView.image = [self.loadingImages objectAtIndex:0];
        }
    } else if([keyPath isEqualToString:@"pullToRefreshProgress"]) {
        if(self.state == LoadingIndicatorViewStatePullToRefresh) {
            CGFloat progress = MAX(0, (self.pullToRefreshProgress * 2 - 1));
            self.imageView.image = [self.loadingImages objectAtIndex:(self.loadingImages.count - 1) * progress];
        }
    }
}

#pragma mark -
#pragma mark Private API
- (void)tick
{
    if(self.ticking) {
        return;
    }
    
    if(self.state == LoadingIndicatorViewStateLoading) {
        NSUInteger index = ([self.spinnerImages indexOfObject:self.imageView.image] + 1) % self.spinnerImages.count;
        self.imageView.image = [self.spinnerImages objectAtIndex:index];
        self.ticking = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:0.05];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ticking = NO;
                [self tick];
            });
        });
    }
}

#pragma mark -
#pragma mark Properties
- (NSArray *)loadingImages
{
    static NSArray *images = nil;
    if(images == nil) {
        images = @[
        [UIImage imageNamed:@"l-01.png"],
        [UIImage imageNamed:@"l-02.png"],
        [UIImage imageNamed:@"l-03.png"],
        [UIImage imageNamed:@"l-04.png"],
        [UIImage imageNamed:@"l-05.png"],
        [UIImage imageNamed:@"l-06.png"],
        [UIImage imageNamed:@"l-07.png"],
        [UIImage imageNamed:@"l-08.png"],
        [UIImage imageNamed:@"l-09.png"],
        [UIImage imageNamed:@"l-10.png"],
        [UIImage imageNamed:@"l-11.png"],
        [UIImage imageNamed:@"l-12.png"],
        [UIImage imageNamed:@"l-13.png"],
        ];
    }
    return images;
}

- (NSArray *)spinnerImages
{
    static NSArray *images = nil;
    if(images == nil) {
        images = @[
        [UIImage imageNamed:@"g-01.png"],
        [UIImage imageNamed:@"g-02.png"],
        [UIImage imageNamed:@"g-03.png"],
        [UIImage imageNamed:@"g-04.png"],
        [UIImage imageNamed:@"g-05.png"],
        [UIImage imageNamed:@"g-06.png"],
        [UIImage imageNamed:@"g-07.png"],
        [UIImage imageNamed:@"g-08.png"],
        [UIImage imageNamed:@"g-09.png"],
        [UIImage imageNamed:@"g-10.png"],
        [UIImage imageNamed:@"g-11.png"],
        [UIImage imageNamed:@"g-12.png"],
        ];
    }
    return images;
}
@end
