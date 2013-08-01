//
//  UserListDataController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserListDataController.h"

@interface UserListDataController()
@property (nonatomic) BOOL loading;
@property (nonatomic, strong) UserListData *data;
@end

@implementation UserListDataController
- (id)init
{
    self = [super init];
    if(self) {
        self.data = [[UserListData alloc] init];
    }
    return self;
}

- (void)reloadList
{
    if(self.loading) {
        return;
    }
    
    self.loading = YES;
    
    APIUserParameters *parameters = [[APIUserParameters alloc] init];
    
    self.apiCallMaker(parameters, ^(NSArray *users, UserListMetadata *meta, NSError *error) {
        [self.data setUsers:users hasMore:meta.hasMore];
        
        self.loading = NO;
    });
}

- (void)loadMore
{
    if(self.loading) {
        return;
    }
    
    self.loading = YES;
    
    APIUserParameters *parameters = [[APIUserParameters alloc] init];
    parameters.beforeID = self.data.minUserID;
    
    self.apiCallMaker(parameters, ^(NSArray *users, UserListMetadata *meta, NSError *error) {
        [self.data addUsersToEnd:users hasMore:meta.hasMore];
        
        self.loading = NO;
    });
}
@end
