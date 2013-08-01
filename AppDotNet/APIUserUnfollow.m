//
//  APIUserUnfollow.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserUnfollow.h"

NSString *APIUserUnfollowDidFinishNotification = @"APIUserUnfollowDidFinishNotification";

@implementation APIUserUnfollow
+ (void)unfollowUserWithID:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler
{
    if(!theUserID || theUserID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"User ID must not be nil and must be non-zero length"];
    }
    
    APIUserUnfollow *api = [[APIUserUnfollow alloc] init];
    api.userCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/follow", theUserID]];
    api.method = VDownloadMethodDELETE;
    api.callType = APICallTypeUser;
    
    [api call];
}
@end
