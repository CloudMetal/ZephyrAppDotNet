//
//  APIUserGet.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserGet.h"

@implementation APIUserGet
+ (void)getUser:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler
{
    if(!theUserID || theUserID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"User ID must not be nil and must be non-zero length"];
    }
        
    APIUserGet *api = [[APIUserGet alloc] init];
    api.userCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@", [theUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    api.method = VDownloadMethodGET;
    api.callType = APICallTypeUser;
    
    [api call];
}
@end
