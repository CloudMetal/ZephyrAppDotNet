//
//  UserFollowersConfiguration.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "UserListConfiguration.h"

@interface UserFollowersConfiguration : UserListConfiguration
@property (nonatomic, copy) NSString *userID;
@end
