//
//  UserFollowingConfiguration.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "UserListConfiguration.h"

@interface UserFollowingConfiguration : UserListConfiguration
@property (nonatomic, copy) NSString *userID;
@end
