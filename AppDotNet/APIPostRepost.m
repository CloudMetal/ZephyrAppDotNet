//
//  APIPostRepost.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIPostRepost.h"

NSString *APIPostRepostDidFinishNotification = @"APIPostRepostDidFinishNotification";

@implementation APIPostRepost
+ (void)repostPostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler
{
    if(!thePostID || thePostID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Post ID for reposting must not be nil and must be non-zero length"];
    }
    
    APIPostRepost *api = [[APIPostRepost alloc] init];
    api.postCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/%@/repost", thePostID]];
    api.method = VDownloadMethodPOST;
    api.callType = APICallTypePost;
    
    [api call];
}
@end
