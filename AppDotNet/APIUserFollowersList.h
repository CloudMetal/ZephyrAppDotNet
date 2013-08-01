//
//  APIUserFollowersList.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

@interface APIUserFollowersList : APICall
+ (void)getUsersFollowingUser:(NSString *)theUserID parameters:(APIUserParameters *)theParameters completionHandler:(void (^)(NSArray *users, UserListMetadata *meta, NSError *error))theCompletionHandler;
@end
