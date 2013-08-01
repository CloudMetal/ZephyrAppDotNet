//
//  UserFollowingConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserFollowingConfiguration.h"

@implementation UserFollowingConfiguration
- (void (^)(APIUserParameters *parameters, APIUserListCallback callback))apiCallMaker
{
    return ([^ (APIUserParameters *parameters, APIUserListCallback callback) {
        [APIUserFollowingList getUsersFollowedByUser:self.userID parameters:parameters completionHandler:callback];
    } copy]);
}
@end
