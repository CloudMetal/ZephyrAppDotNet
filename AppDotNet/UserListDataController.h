//
//  UserListDataController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "UserListData.h"
#import "API.h"

@interface UserListDataController : NSObject
@property (nonatomic, copy) void (^apiCallMaker)(APIUserParameters *parameters, APIUserListCallback callback);

@property (nonatomic, readonly, strong) UserListData *data;

- (void)reloadList;
- (void)loadMore;
@end
