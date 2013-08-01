//
//  APITokenCheck.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APITokenCheck.h"

@implementation APITokenCheck
+ (void)checkTokenWithCompletionHandler:(void (^)(User *user, NSError *error))theCompletionHandler
{
    APITokenCheck *api = [[APITokenCheck alloc] init];
    api.userCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/token"]];
    api.method = VDownloadMethodGET;
    api.callType = APICallTypeToken;
    
    [api call];
}
@end
