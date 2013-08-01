//
//  ActivityNotificationView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ActivityNotificationView.h"

@interface ActivityNotificationView()
@property (nonatomic, strong) NSMutableArray *activityStack;
@property (nonatomic) BOOL performingActivity;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIActivityIndicatorView *runningView;
@property (nonatomic, strong) UIImageView *acceptedView;
@property (nonatomic, strong) UIImageView *rejectedView;

- (void)setRotation:(BOOL)animated;
- (void)performNextActivity;
- (void)finishedActivity;
@end

@implementation ActivityNotificationView
- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 80, 80)];
    if(self) {
        self.activityStack = [[NSMutableArray alloc] init];
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundImageView.image = [[UIImage imageNamed:@"toast-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        [self addSubview:self.backgroundImageView];
        
        self.runningView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.runningView.center = CGPointMake(40, 40);
        [self addSubview:self.runningView];
        [self.runningView startAnimating];
        
        self.acceptedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast-checkmark.png"]];
        self.acceptedView.center = CGPointMake(40, 40);
        [self addSubview:self.acceptedView];
        
        self.rejectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast-failed.png"]];
        self.rejectedView.center = CGPointMake(40, 40);
        [self addSubview:self.rejectedView];
        
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:0];
        
        [self setRotation:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"]) {
        [self.activityStack addObject:@"updateState"];
        [self performNextActivity];
    }
}

- (void)showInWindow:(UIWindow *)theWindow animated:(BOOL)animated
{
    self.center = CGPointMake(theWindow.bounds.size.width * 0.5, theWindow.bounds.size.height * 0.5);
    [theWindow addSubview:self];
    
    if(animated) {
        [self.activityStack addObject:@"animateEntrance"];
        [self performNextActivity];
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if(animated) {
        [self.activityStack addObject:@"animateExit"];
        [self performNextActivity];
    } else {
        [self removeFromSuperview];
    }
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification
{
    [self setRotation:YES];
}

- (void)setRotation:(BOOL)animated
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
        transform = CGAffineTransformIdentity;
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        transform = CGAffineTransformMakeRotation(M_PI);
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeRotation(M_PI * 1.5);
    }
    
    if(animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = transform;
        }];
    } else {
        self.transform = transform;
    }
}

- (void)performNextActivity
{
    if(self.performingActivity) {
        return;
    }
    
    if(self.activityStack.count == 0) {
        return;
    }
    
    self.performingActivity = YES;
    NSString *nextActivity = [self.activityStack objectAtIndex:0];
    [self.activityStack removeObjectAtIndex:0];
    
    if([nextActivity isEqualToString:@"updateState"]) {
        self.runningView.hidden = self.state != ActivityNotificationViewStateRunning;
        self.acceptedView.hidden = self.state != ActivityNotificationViewStateAccepted;
        self.rejectedView.hidden = self.state != ActivityNotificationViewStateRejected;
        
        [self finishedActivity];
    } else if([nextActivity isEqualToString:@"animateEntrance"]) {
        CGAffineTransform transform = self.transform;
        self.alpha = 0;
        self.transform = CGAffineTransformScale(transform, 0.8, 0.8);
        [UIView animateWithDuration:0.15 animations:^{
            self.alpha = 1;
            self.transform = CGAffineTransformScale(transform, 1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.075 animations:^{
                self.transform = transform;
            } completion:^(BOOL finished) {
                [self performSelector:@selector(finishedActivity) withObject:nil afterDelay:0.25];
            }];
        }];
    } else if([nextActivity isEqualToString:@"animateExit"]) {
        CGAffineTransform transform = self.transform;
        [UIView animateWithDuration:0.075 delay:0.5 options:0 animations:^{
            self.transform = CGAffineTransformScale(transform, 1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.alpha = 0;
                self.transform = CGAffineTransformScale(transform, 0.8, 0.8);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [self finishedActivity];
            }];
        }];
    }
}

- (void)finishedActivity
{
    self.performingActivity = NO;
    [self performNextActivity];
}
@end
