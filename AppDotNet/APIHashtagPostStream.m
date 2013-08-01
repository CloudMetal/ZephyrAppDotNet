//
//  APIHashtagPostStream.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIHashtagPostStream.h"

@implementation APIHashtagPostStream
+ (void)getHashtagPostStreamWithParameters:(APIPostParameters *)theParameters hashtag:(NSString *)hashtag completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler
{
    if(!hashtag) {
        [NSException raise:NSInvalidArgumentException format:@"hashtag cannot be nil."];
    }
    
    APIHashtagPostStream *stream = [[APIHashtagPostStream alloc] init];
    stream.postListCallback = theCompletionHandler;
    stream.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/tag/%@", [hashtag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    stream.parameters = theParameters.parameterDictionary;
    stream.method = VDownloadMethodGET;
    stream.callType = APICallTypePostList;
    
    [stream call];
}
@end
