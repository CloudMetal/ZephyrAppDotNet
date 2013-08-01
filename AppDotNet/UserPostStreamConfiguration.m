//
//  UserPostStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserPostStreamConfiguration.h"

@implementation UserPostStreamConfiguration
- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIUserPostStream getUserPostStreamWithParameters:parameters userID:self.userID completionHandler:callback];
    } copy];
}
@end
