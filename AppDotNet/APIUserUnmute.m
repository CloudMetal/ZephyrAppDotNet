//
//  APIUserUnmute.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserUnmute.h"

NSString *APIUserUnmuteDidFinishNotification = @"APIUserUnmuteDidFinishNotification";

@implementation APIUserUnmute
+ (void)unmuteUserWithID:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler;
{
    if(!theUserID || theUserID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"User ID must not be nil and must be non-zero length"];
    }
    
    APIUserUnmute *api = [[APIUserUnmute alloc] init];
    api.userCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/mute", theUserID]];
    api.method = VDownloadMethodDELETE;
    api.callType = APICallTypeUser;
    
    [api call];
}
@end