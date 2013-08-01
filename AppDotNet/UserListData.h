//
//  UserListData.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface UserListData : NSObject
@property (nonatomic, readonly, copy) NSArray *users;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) NSString *minUserID;
@property (nonatomic, readonly) NSString *maxUserID;

/* This method should only be called for the initial fill of a table */
- (void)setUsers:(NSArray *)theNewUsers hasMore:(BOOL)hasMore;

/* This method should only be called for the "Pull to Refresh" fetch */
- (void)insertUsersToFront:(NSArray *)theNewUsers hasMore:(BOOL)hasMore;

/* This method should be called with the results of a load more action triggered by scrolling to the end of a table */
- (void)addUsersToEnd:(NSArray *)theNewUsers hasMore:(BOOL)hasMore;
@end
