//
//  UserListConfiguration.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APIUserParameters.h"
#import "API.h"

@interface UserListConfiguration : NSObject
@property (nonatomic, readonly) void (^apiCallMaker)(APIUserParameters *parameters, APIUserListCallback callback);
@end
