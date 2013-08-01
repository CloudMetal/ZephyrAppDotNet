//
//  APIPostStar.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIPostStar.h"

NSString *APIPostStarDidFinishNotification = @"APIPostStarDidFinishNotification";

@implementation APIPostStar
+ (void)starPostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler
{
    if(!thePostID || thePostID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Post ID for starring must not be nil and must be non-zero length"];
    }
    
    APIPostStar *api = [[APIPostStar alloc] init];
    api.postCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/%@/star", thePostID]];
    api.method = VDownloadMethodPOST;
    api.callType = APICallTypePost;
    
    [api call];
}
@end
