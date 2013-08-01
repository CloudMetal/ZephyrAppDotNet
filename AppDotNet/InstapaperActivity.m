//
//  InstapaperActivity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "InstapaperActivity.h"
#import "Instapaper.h"

@interface InstapaperActivity()
@property (nonatomic, copy) NSArray *urls;
@end

@implementation InstapaperActivity
- (NSString *)activityType
{
    return @"com.enderlabs.net3000instapaper";
}

- (NSString *)activityTitle
{
    return @"Instapaper";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"share-instapaper.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for(id item in activityItems) {
        if(![item isKindOfClass:[NSURL class]]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.urls = activityItems;
}

- (void)performActivity
{
    for(NSURL *url in self.urls) {
        [[Instapaper sharedInstapaper] sendURLToInstapaper:url];
    }
    
    [self activityDidFinish:YES];
}
@end
