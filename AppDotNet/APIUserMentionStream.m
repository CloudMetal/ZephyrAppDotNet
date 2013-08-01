//
//  APIUserMentionStream.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserMentionStream.h"

@implementation APIUserMentionStream
+ (void)getUserMentionStreamWithParameters:(APIPostParameters *)theParameters userID:(NSString *)userID completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler
{
    if(!userID) {
        userID = @"me";
    }
    
    APIUserMentionStream *stream = [[APIUserMentionStream alloc] init];
    stream.postListCallback = theCompletionHandler;
    stream.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/mentions", [userID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    stream.parameters = theParameters.parameterDictionary;
    stream.method = VDownloadMethodGET;
    stream.callType = APICallTypePostList;
    
    [stream call];
}
@end
