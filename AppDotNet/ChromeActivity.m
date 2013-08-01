//
//  ChromeActivity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ChromeActivity.h"

@interface ChromeActivity()
@property (nonatomic, copy) NSArray *urls;
@end

@implementation ChromeActivity
+ (BOOL)canShareToChrome
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://www.googlechrome.com/"]];
}

- (NSString *)activityType
{
    return @"com.enderlabs.net3000chrome";
}

- (NSString *)activityTitle
{
    return @"Chrome";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"share-chrome.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://www.googlechrome.com/"]] == NO) {
        return NO;
    }
    
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
        NSString *scheme = url.scheme;
        
        NSString *chromeScheme = @"googlechrome";
        if([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }
        
        NSString *absoluteString = url.absoluteString;
        NSRange schemeRange = [absoluteString rangeOfString:@":"];
        NSString *urlWithoutScheme = [absoluteString substringFromIndex:schemeRange.location];
        NSString *chromeURLString = [chromeScheme stringByAppendingString:urlWithoutScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        [[UIApplication sharedApplication] openURL:chromeURL];
        
        break;
    }
    
    [self activityDidFinish:YES];
}
@end
