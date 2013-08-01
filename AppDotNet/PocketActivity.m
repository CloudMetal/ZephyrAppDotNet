//
//  PocketActivity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PocketActivity.h"
#import "Pocket.h"

@interface PocketActivity()
@property (nonatomic, copy) NSArray *urls;
@end

@implementation PocketActivity
- (NSString *)activityType
{
    return @"com.enderlabs.net3000pocket";
}

- (NSString *)activityTitle
{
    return @"Pocket";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"share-pocket.png"];
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
        [[Pocket sharedPocket] sendURLToPocket:url title:nil];
    }
    
    [self activityDidFinish:YES];
}
@end
