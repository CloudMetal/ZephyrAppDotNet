//
//  UserSearchConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserSearchConfiguration.h"

@implementation UserSearchConfiguration
- (void (^)(APIUserParameters *parameters, APIUserListCallback callback))apiCallMaker
{
    return ([^ (APIUserParameters *parameters, APIUserListCallback callback) {
        [APIUserSearchList searchUsersWithQuery:self.query parameters:parameters completionHandler:callback];
    } copy]);
}
@end
