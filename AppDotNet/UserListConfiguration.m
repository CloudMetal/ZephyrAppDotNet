//
//  UserListConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserListConfiguration.h"

@implementation UserListConfiguration
- (void (^)(APIUserParameters *parameters, APIUserListCallback callback))apiCallMaker
{
    [NSException raise:NSGenericException format:@"Must subclass apiCallMaker"];
    return nil;
}
@end
