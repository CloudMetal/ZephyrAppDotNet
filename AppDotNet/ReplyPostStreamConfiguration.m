//
//  ReplyPostStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ReplyPostStreamConfiguration.h"

@implementation ReplyPostStreamConfiguration
- (PostStreamIdiom)idiom
{
    return PostStreamIdiomThread;
}

- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIReplyPostStream getReplyPostStreamWithParameters:parameters postID:self.postID completionHandler:callback];
    } copy];
}
@end
