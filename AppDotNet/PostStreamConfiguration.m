//
//  PostStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostStreamConfiguration.h"

@implementation PostStreamConfiguration
- (BOOL)updatesStreamMarker
{
    return NO;
}

- (BOOL)shouldOnlyAutoRefreshWhenVisible
{
    return NO;
}

- (BOOL)savesPosts
{
    return NO;
}

- (NSString *)savedStreamName
{
    NSAssert(self.savesPosts == NO, @"If savesPosts == YES, then savedStreamName must be overrided");
    return nil;
}

- (PostStreamIdiom)idiom
{
    return PostStreamIdiomStream;
}

- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    [NSException raise:NSGenericException format:@"Must subclass apiCallMaker"];
    return nil;
}
@end
