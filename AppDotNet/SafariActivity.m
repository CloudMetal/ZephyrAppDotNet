//
//  SafariActivity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "SafariActivity.h"

@interface SafariActivity()
@property (nonatomic, copy) NSArray *urls;
@end

@implementation SafariActivity
- (NSString *)activityType
{
    return @"com.enderlabs.net3000safari";
}

- (NSString *)activityTitle
{
    return @"Safari";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"share-safari.png"];
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
        [[UIApplication sharedApplication] openURL:url];
        break;
    }
    
    [self activityDidFinish:YES];
}
@end
