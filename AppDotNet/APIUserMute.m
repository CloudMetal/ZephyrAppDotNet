//
//  APIUserMute.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserMute.h"

NSString *APIUserMuteDidFinishNotification = @"APIUserMuteDidFinishNotification";

@implementation APIUserMute
+ (void)muteUserWithID:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler;
{
    if(!theUserID || theUserID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"User ID must not be nil and must be non-zero length"];
    }
    
    APIUserMute *api = [[APIUserMute alloc] init];
    api.userCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/mute", theUserID]];
    api.method = VDownloadMethodPOST;
    api.callType = APICallTypeUser;
    
    [api call];
}
@end
