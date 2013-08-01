//
//  GlobalPostStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "GlobalPostStreamConfiguration.h"

@implementation GlobalPostStreamConfiguration
- (BOOL)updatesStreamMarker
{
    return YES;
}

- (BOOL)shouldOnlyAutoRefreshWhenVisible
{
    return YES;
}

- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIGlobalPostStream getGlobalPostStreamWithParameters:parameters completionHandler:callback];
    } copy];
}
@end
