//
//  UserMutedConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserMutedConfiguration.h"

@implementation UserMutedConfiguration
- (void (^)(APIUserParameters *parameters, APIUserListCallback callback))apiCallMaker
{
    return ([^ (APIUserParameters *parameters, APIUserListCallback callback) {
        [APIUserMutedList getMutedUsersWithParameters:parameters completionHandler:callback];
    } copy]);
}
@end
