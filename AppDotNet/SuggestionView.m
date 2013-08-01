//
//  SuggestionView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "SuggestionView.h"

@interface SuggestionView()
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)finishInit;

- (void)registerObservers;
- (void)unregisterObservers;

- (void)reloadData;
@end

@implementation SuggestionView
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    [self registerObservers];
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"suggestions"]) {
        [self reloadData];
    }
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"suggestions" options:0 context:0];
}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"suggestions"];
}

- (void)reloadData
{
    NSMutableArray *widths = [[NSMutableArray alloc] init];
    CGFloat widthSum = 0;
    for(NSString *suggestion in self.suggestions) {
        CGFloat width = [suggestion sizeWithFont:[UIFont boldSystemFontOfSize:15]].width + 20;
        widthSum += width;
        [widths addObject:[NSNumber numberWithFloat:width]];
    }
    
    self.scrollView.contentSize = CGSizeMake(widthSum, self.bounds.size.height);
    self.scrollView.contentOffset = CGPointZero;
    
    while(self.scrollView.subviews.count > 0) {
        [[self.scrollView.subviews lastObject] removeFromSuperview];
    }
    
    CGFloat left = 0;
    for(NSInteger i=0; i<self.suggestions.count; i++) {
        NSString *suggestion = [self.suggestions objectAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(left, 0, [[widths objectAtIndex:i] floatValue], 44);
        [button setTitle:suggestion forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        left += [[widths objectAtIndex:i] floatValue];
    }
}

- (void)buttonTapped:(id)sender
{
    [self.delegate suggestionView:self suggestedValue:[sender titleForState:UIControlStateNormal]];
}
@end
