//
//  UserPostStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserPersonalStreamConfiguration.h"

@implementation UserPersonalStreamConfiguration
- (BOOL)updatesStreamMarker
{
    return YES;
}

- (BOOL)savesPosts
{
    return YES;
}

- (NSString *)savedStreamName
{
    return @"UserPersonalStream";
}

- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIUserPersonalStream getUserPersonalStreamWithParameters:parameters completionHandler:callback];
    } copy];
}
@end
