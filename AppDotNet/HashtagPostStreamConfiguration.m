//
//  HashtagPostStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "HashtagPostStreamConfiguration.h"

@implementation HashtagPostStreamConfiguration
- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIHashtagPostStream getHashtagPostStreamWithParameters:parameters hashtag:self.hashtag completionHandler:callback];
    } copy];
}
@end
