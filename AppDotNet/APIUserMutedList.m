//
//  APIUserMutedList.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserMutedList.h"

@implementation APIUserMutedList
+ (void)getMutedUsersWithParameters:(APIUserParameters *)theParameters completionHandler:(void (^)(NSArray *users, UserListMetadata *meta, NSError *error))theCompletionHandler
{
    APIUserMutedList *api = [[APIUserMutedList alloc] init];
    api.userListCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/me/muted"]];
    api.method = VDownloadMethodGET;
    api.callType = APICallTypeUserList;
    api.parameters = theParameters.parameterDictionary;
    
    [api call];
}
@end
