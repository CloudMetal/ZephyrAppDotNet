//
//  UserListData.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserListData.h"
#import "User.h"

@interface UserListData()
@property (nonatomic, copy) NSArray *users;
@property (nonatomic) BOOL hasMore;
@end

@implementation UserListData
#pragma mark -
#pragma mark Properties
- (NSString *)minUserID
{
    User *user = [self.users lastObject];
    return user.userID;
}

- (NSString *)maxUserID
{
    User *user = [self.users objectAtIndex:0];
    return user.userID;
}

#pragma mark -
#pragma mark Public API
- (void)setUsers:(NSArray *)theNewUsers hasMore:(BOOL)hasMore
{
    self.users = theNewUsers;
    self.hasMore = hasMore;
}

- (void)insertUsersToFront:(NSArray *)theNewUsers hasMore:(BOOL)hasMore;
{
    self.users = [theNewUsers arrayByAddingObjectsFromArray:self.users];
}

- (void)addUsersToEnd:(NSArray *)theNewUsers hasMore:(BOOL)hasMore
{
    self.users = [self.users arrayByAddingObjectsFromArray:theNewUsers];
    self.hasMore = hasMore;
}
@end
