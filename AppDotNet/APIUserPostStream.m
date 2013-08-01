//
//  APIUserPostStream.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserPostStream.h"

@implementation APIUserPostStream
+ (void)getUserPostStreamWithParameters:(APIPostParameters *)theParameters userID:(NSString *)userID completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler;
{
    if(!userID) {
        userID = @"me";
    }
    
    APIUserPostStream *stream = [[APIUserPostStream alloc] init];
    stream.postListCallback = theCompletionHandler;
    stream.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/posts", userID]];
    stream.parameters = theParameters.parameterDictionary;
    stream.method = VDownloadMethodGET;
    stream.callType = APICallTypePostList;
    
    [stream call];
}
@end
