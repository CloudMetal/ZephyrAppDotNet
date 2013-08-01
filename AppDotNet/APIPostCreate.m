//
//  APIPostCreate.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIPostCreate.h"

NSString *APIPostCreateDidFinishNotification = @"APIPostCreateDidFinishNotification";

@implementation APIPostCreate
+ (void)createPostWithText:(NSString *)text replyUserID:(NSString *)theReplyUserID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler
{
    if(!text || text.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Text must not be nil and must be non-zero length"];
    }
    
    if(theReplyUserID.length == 0) {
        theReplyUserID = nil;
    }
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:text forKey:@"text"];
    
    if(theReplyUserID) {
        [postData setObject:theReplyUserID forKey:@"reply_to"];
    }
    
    APIPostCreate *api = [[APIPostCreate alloc] init];
    api.postCallback = theCompletionHandler;
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts"]];
    api.bodyData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:0];
    api.HTTPHeaderFields = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"content-type"];
    api.method = VDownloadMethodPOST;
    api.callType = APICallTypePost;
    
    [api call];
}
@end
