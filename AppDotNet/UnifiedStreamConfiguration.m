//
//  UnifiedStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UnifiedStreamConfiguration.h"
#import "API.h"

@implementation UnifiedStreamConfiguration
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
    return @"UnifiedStream";
}

- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIUnifiedStream getUnifiedStreamWithParameters:parameters completionHandler:callback];
    } copy];
}
@end
