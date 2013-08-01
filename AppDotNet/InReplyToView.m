//
//  InReplyToView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "InReplyToView.h"

@interface InReplyToView()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *dragAffordanceView;

- (void)finishInit;
@end

@implementation InReplyToView
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
    UIColor *postBackgroundColor = [UIColor postBackgroundColor];
    CGFloat red, green, blue, alpha;
    [postBackgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.backgroundColor = [UIColor colorWithRed:red * 0.9 green:green * 0.9 blue:blue * 0.9 alpha:1];
    UIColor *strokeColor = [UIColor colorWithRed:red * 0.85 green:green * 0.85 blue:blue * 0.85 alpha:1];
    
    self.dragAffordanceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drag-affordance.png"]];
    self.dragAffordanceView.frame = CGRectMake(0, 0, self.dragAffordanceView.image.size.width, self.dragAffordanceView.image.size.height);
    [self addSubview:self.dragAffordanceView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.label.opaque = NO;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.font = [UIFont boldSystemFontOfSize:13];
    self.label.textColor = [UIColor postUserNameColor];
    self.label.text = @"In reply to @null";
    [self addSubview:self.label];
    
    UIView *bottomStroke = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
    bottomStroke.backgroundColor = strokeColor;
    bottomStroke.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bottomStroke];
    
    UIView *topStroke = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    topStroke.backgroundColor = strokeColor;
    topStroke.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:topStroke];
    
    [self addObserver:self forKeyPath:@"replyID" options:0 context:0];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"replyID"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"replyID"]) {
        self.label.text = [NSString stringWithFormat:@"In reply to @%@", self.replyID];
    }
}

- (void)layoutSubviews
{
    CGFloat labelFontHeight = roundf([self.label.text sizeWithFont:self.label.font].height);
    CGFloat labelTop = roundf((self.bounds.size.height - labelFontHeight) * 0.5);
    self.label.frame = CGRectMake(10, labelTop, self.bounds.size.width - 20, labelFontHeight);
    
    CGFloat dragAffordanceHeight = self.dragAffordanceView.bounds.size.height;
    CGFloat dragAffordanceTop = roundf((self.bounds.size.height - dragAffordanceHeight) * 0.5);
    self.dragAffordanceView.frame = CGRectMake(self.bounds.size.width - (self.dragAffordanceView.bounds.size.width + 5), dragAffordanceTop - 2, self.dragAffordanceView.bounds.size.width, self.dragAffordanceView.bounds.size.height);
}

#pragma mark -
#pragma mark Gesture Recognizers
- (void)pan:(UIPanGestureRecognizer *)thePanGestureRecognizer
{
    if(thePanGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if(self.panBlock) {
            self.panBlock([thePanGestureRecognizer translationInView:self.superview].y);
        }
    } else if(thePanGestureRecognizer.state == UIGestureRecognizerStateEnded || thePanGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if(self.panFinishedBlock) {
            self.panFinishedBlock();
        }
    }
}
@end
