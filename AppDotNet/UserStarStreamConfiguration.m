//
//  UserStarStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserStarStreamConfiguration.h"

@implementation UserStarStreamConfiguration
- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIUserStarStream getUserStarStreamWithParameters:parameters userID:self.userID completionHandler:callback];
    } copy];
}
@end
