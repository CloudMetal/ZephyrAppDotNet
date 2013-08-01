//
//  LoadMoreView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "LoadMoreView.h"

@interface LoadMoreView()
@property (nonatomic, strong) UILabel *loadingMoreLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation LoadMoreView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor postBackgroundColor];
        
        self.loadingMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.loadingMoreLabel.text = @"Loading more...";
        self.loadingMoreLabel.textColor = [UIColor postUserNameColor];
        self.loadingMoreLabel.backgroundColor = [UIColor postBackgroundColor];
        self.loadingMoreLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:self.loadingMoreLabel];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicatorView startAnimating];
        [self addSubview:self.activityIndicatorView];
        
        UIView *topStrokeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        topStrokeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topStrokeView.backgroundColor = [UIColor postTopStrokeColor];
        [self addSubview:topStrokeView];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.loadingMoreLabel sizeToFit];
    
    CGSize loadingMoreSize = self.loadingMoreLabel.bounds.size;
    CGSize activityIndicatorSize = self.activityIndicatorView.bounds.size;
    
    CGFloat loadingMoreLeft = roundf((self.bounds.size.width - loadingMoreSize.width) * 0.5);
    CGFloat loadingMoreTop = roundf((self.bounds.size.height - loadingMoreSize.height) * 0.5);
    
    CGFloat activityIndicatorLeft = loadingMoreLeft - (10 + activityIndicatorSize.width);
    CGFloat activityIndicatorTop = roundf((self.bounds.size.height - activityIndicatorSize.height) * 0.5);
    
    self.loadingMoreLabel.frame = CGRectMake(loadingMoreLeft, loadingMoreTop, loadingMoreSize.width, loadingMoreSize.height);
    self.activityIndicatorView.frame = CGRectMake(activityIndicatorLeft, activityIndicatorTop, activityIndicatorSize.width, activityIndicatorSize.height);
}
@end
