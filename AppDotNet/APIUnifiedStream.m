//
//  APIUnifiedStream.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUnifiedStream.h"

@implementation APIUnifiedStream
+ (void)getUnifiedStreamWithParameters:(APIPostParameters *)theParameters completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler
{
    APIUnifiedStream *stream = [[APIUnifiedStream alloc] init];
    stream.postListCallback = theCompletionHandler;
    stream.url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/unified"];
    stream.parameters = theParameters.parameterDictionary;
    stream.method = VDownloadMethodGET;
    stream.callType = APICallTypePostList;
    
    [stream call];
}
@end
