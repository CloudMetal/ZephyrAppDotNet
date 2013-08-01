//
//  PullToRefreshView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PullToRefreshView.h"
#import "LoadingIndicatorView.h"

@interface PullToRefreshView()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LoadingIndicatorView *loadingIndicatorView;
@end

@implementation PullToRefreshView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, -50, self.bounds.size.width, 50)];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.opaque = NO;
        [self addSubview:self.contentView];
        
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"pullProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        
        self.loadingIndicatorView = [[LoadingIndicatorView alloc] initWithFrame:self.contentView.bounds];
        self.loadingIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.loadingIndicatorView];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"state"];
    [self removeObserver:self forKeyPath:@"pullProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"]) {
        if([[change objectForKey:NSKeyValueChangeOldKey] intValue] != [[change objectForKey:NSKeyValueChangeNewKey] intValue]) {
            if(self.state == PullToRefreshStatePromptToPull) {
                self.loadingIndicatorView.state = LoadingIndicatorViewStatePullToRefresh;
                self.loadingIndicatorView.pullToRefreshProgress = 0.0;
            } else if(self.state == PullToRefreshStatePromptToRelease) {
                self.loadingIndicatorView.state = LoadingIndicatorViewStatePullToRefresh;
                self.loadingIndicatorView.pullToRefreshProgress = 1.0f;
            } else if(self.state == PullToRefreshStateLoading) {
                self.loadingIndicatorView.state = LoadingIndicatorViewStateLoading;
            }
        }
    } else if([keyPath isEqualToString:@"pullProgress"]) {
        self.loadingIndicatorView.pullToRefreshProgress = self.pullProgress;
    }
}
@end
