//
//  APIUserSearchList.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserSearchList.h"

@implementation APIUserSearchList
+ (void)searchUsersWithQuery:(NSString *)theQuery parameters:(APIUserParameters *)theParameters completionHandler:(void (^)(NSArray *users, UserListMetadata *meta, NSError *error))theCompletionHandler
{
    if(!theQuery || theQuery.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Query must not be nil and must be non-zero length"];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:theParameters.parameterDictionary];
    
    [parameters setObject:theQuery forKey:@"q"];
    
    APIUserSearchList *api = [[APIUserSearchList alloc] init];
    api.userListCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/search"]];
    api.method = VDownloadMethodGET;
    api.callType = APICallTypeUserList;
    api.parameters = parameters;
    
    [api call];
}
@end
