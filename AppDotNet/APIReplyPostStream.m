//
//  APIReplyPostStream.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIReplyPostStream.h"

@implementation APIReplyPostStream
+ (void)getReplyPostStreamWithParameters:(APIPostParameters *)theParameters postID:(NSString *)thePostID completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler;
{
    if(!thePostID) {
        [NSException raise:NSInvalidArgumentException format:@"Post ID must not be nil"];
    }
    
    APIReplyPostStream *stream = [[APIReplyPostStream alloc] init];
    stream.postListCallback = theCompletionHandler;
    stream.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/%@/replies", thePostID]];
    stream.parameters = theParameters.parameterDictionary;
    stream.method = VDownloadMethodGET;
    stream.callType = APICallTypePostList;
    
    [stream call];
}
@end
