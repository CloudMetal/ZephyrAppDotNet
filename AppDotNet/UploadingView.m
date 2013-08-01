//
//  UploadingView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UploadingView.h"

static NSMutableArray *uploadingViewWindows = nil;

@interface UploadingView()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *uploadingLabel;
@property (nonatomic, strong) UIButton *cancelButton;

- (void)rotateContentViewToStatusBarOrientationAnimated:(BOOL)animated;
@end

@implementation UploadingView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView];
        
        self.uploadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        self.uploadingLabel.opaque = NO;
        self.uploadingLabel.backgroundColor = [UIColor clearColor];
        self.uploadingLabel.textColor = [UIColor whiteColor];
        self.uploadingLabel.shadowColor = [UIColor blackColor];
        self.uploadingLabel.shadowOffset = CGSizeMake(0, 1);
        self.uploadingLabel.font = [UIFont boldSystemFontOfSize:15];
        self.uploadingLabel.textAlignment = UITextAlignmentCenter;
        self.uploadingLabel.text = @"Uploading...";
        [self.uploadingLabel sizeToFit];
        [self.contentView addSubview:self.uploadingLabel];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityIndicator sizeToFit];
        [self.contentView addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
        
        UIImage *braceButtonImage = [[UIImage imageNamed:@"brace-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        UIImage *pressedBraceButtonImage = [[UIImage imageNamed:@"brace-button-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setBackgroundImage:braceButtonImage forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:pressedBraceButtonImage forState:UIControlStateHighlighted];
        [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.cancelButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.cancelButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        self.cancelButton.frame = CGRectMake(0, self.contentView.bounds.size.height - 44, self.contentView.bounds.size.width, 44);
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.contentView addSubview:self.cancelButton];
        [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        
        [self rotateContentViewToStatusBarOrientationAnimated:NO];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)layoutSubviews
{
    self.contentView.center = self.center;
    
    CGFloat width = self.activityIndicator.bounds.size.width + 7 + self.uploadingLabel.bounds.size.width;
    CGFloat left = roundf((self.contentView.bounds.size.width - width) * 0.5);
    
    self.activityIndicator.frame = CGRectMake(left, 0, self.activityIndicator.bounds.size.width, self.activityIndicator.bounds.size.height);
    self.uploadingLabel.frame = CGRectMake(left + self.activityIndicator.bounds.size.width + 7, 0, self.uploadingLabel.bounds.size.width, self.activityIndicator.bounds.size.height);
}

- (void)statusBarOrientationWillChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rotateContentViewToStatusBarOrientationAnimated:YES];
    });
}

- (void)show
{
    if(uploadingViewWindows == nil) {
        uploadingViewWindows = [[NSMutableArray alloc] init];
    }
    
    UIScreen *screen = [UIScreen mainScreen];
    self.frame = screen.bounds;
       
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]];
    window.windowLevel = UIWindowLevelAlert;
    [window addSubview:self];
    [uploadingViewWindows addObject:window];

    [window makeKeyAndVisible];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [uploadingViewWindows removeObject:self.window];
    }];
}

- (void)rotateContentViewToStatusBarOrientationAnimated:(BOOL)animated
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeRotation(M_PI * 1.5);
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }
    
    if(animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.transform = transform;
        }];
    } else {
        self.contentView.transform = transform;
    }
}

- (void)cancel:(id)sender
{
    [self dismiss];
    
    if(self.uploadingViewDidCancelCallback) {
        self.uploadingViewDidCancelCallback();
    }
}
@end
