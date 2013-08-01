//
//  NetworkActivityController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "NetworkActivityController.h"

@interface NetworkActivityController()
@property (nonatomic) BOOL reloadingActivityIndicator;
@property (nonatomic) NSUInteger networkActivityCount;
@property (nonatomic) BOOL performingWebViewActivity;

- (void)setNeedsToReloadActivityIndicator;
@end

@implementation NetworkActivityController
+ (NetworkActivityController *)sharedNetworkActivityController
{
    static NetworkActivityController *networkActivityController = nil;
    if(!networkActivityController) {
        networkActivityController = [[NetworkActivityController alloc] init];
    }
    return networkActivityController;
}

#pragma mark -
#pragma mark Private API
- (void)setNeedsToReloadActivityIndicator
{
    if(self.reloadingActivityIndicator) {
        return;
    }
    
    self.reloadingActivityIndicator = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.reloadingActivityIndicator = NO;
            
            if(self.networkActivityCount > 0 || self.performingWebViewActivity) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            } else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        });
    });
}

#pragma mark -
#pragma mark Public API

- (void)addNetworkActivity
{
    self.networkActivityCount++;
    [self setNeedsToReloadActivityIndicator];
}

- (void)removeNetworkActivity
{
    if(self.networkActivityCount > 0) {
        self.networkActivityCount--;
    }
    [self setNeedsToReloadActivityIndicator];
}

- (void)beginWebViewActivity
{
    self.performingWebViewActivity = YES;
    [self setNeedsToReloadActivityIndicator];
}

- (void)endWebViewActivity
{
    self.performingWebViewActivity = NO;
    [self setNeedsToReloadActivityIndicator];
}
@end
