//
//  UserFollowersConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserFollowersConfiguration.h"

@implementation UserFollowersConfiguration
- (void (^)(APIUserParameters *parameters, APIUserListCallback callback))apiCallMaker
{
    return ([^ (APIUserParameters *parameters, APIUserListCallback callback) {
        [APIUserFollowersList getUsersFollowingUser:self.userID parameters:parameters completionHandler:callback];
    } copy]);
}
@end
