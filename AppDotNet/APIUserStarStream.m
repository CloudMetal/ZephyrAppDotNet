//
//  APIUserStarStream.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserStarStream.h"

@implementation APIUserStarStream
+ (void)getUserStarStreamWithParameters:(APIPostParameters *)theParameters userID:(NSString *)userID completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler
{
    if(!userID) {
        userID = @"me";
    }
    
    APIUserStarStream *stream = [[APIUserStarStream alloc] init];
    stream.postListCallback = theCompletionHandler;
    stream.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/%@/stars", [userID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    stream.parameters = theParameters.parameterDictionary;
    stream.method = VDownloadMethodGET;
    stream.callType = APICallTypePostList;
    
    [stream call];
}
@end
