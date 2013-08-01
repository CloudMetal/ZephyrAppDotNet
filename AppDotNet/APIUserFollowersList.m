//
//  APIUserFollowersList.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserFollowersList.h"

@implementation APIUserFollowersList
+ (void)getUsersFollowingUser:(NSString *)theUserID parameters:(APIUserParameters *)theParameters completionHandler:(void (^)(NSArray *users, UserListMetadata *meta, NSError *error))theCompletionHandler
{
    if(!theUserID || theUserID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"User ID must not be nil and must be non-zero length"];
    }
    
    APIUserFollowersList *api = [[APIUserFollowersList alloc] init];
    api.userListCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/followers", theUserID]];
    api.method = VDownloadMethodGET;
    api.callType = APICallTypeUserList;
    api.parameters = theParameters.parameterDictionary;
    
    [api call];
}
@end
