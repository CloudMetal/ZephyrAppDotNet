//
//  APIPostUnstar.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIPostUnstar.h"

NSString *APIPostUnstarDidFinishNotification = @"APIPostUnstarDidFinishNotification";

@implementation APIPostUnstar
+ (void)unstarPostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler
{
    if(!thePostID || thePostID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Post ID for deletion must not be nil and must be non-zero length"];
    }
    
    APIPostUnstar *api = [[APIPostUnstar alloc] init];
    api.postCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/%@/star", thePostID]];
    api.method = VDownloadMethodDELETE;
    api.callType = APICallTypePost;
    
    [api call];
}
@end
