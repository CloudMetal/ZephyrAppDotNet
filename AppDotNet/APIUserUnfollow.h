//
//  APIUserUnfollow.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIUserUnfollowDidFinishNotification;

@interface APIUserUnfollow : APICall
+ (void)unfollowUserWithID:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler;
@end
