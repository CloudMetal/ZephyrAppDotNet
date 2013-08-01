//
//  UserSearchConfiguration.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "UserListConfiguration.h"

@interface UserSearchConfiguration : UserListConfiguration
@property (nonatomic, copy) NSString *query;
@end
