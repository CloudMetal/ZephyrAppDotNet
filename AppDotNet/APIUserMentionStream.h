//
//  APIUserMentionStream.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//
#import <Foundation/Foundation.h>
#import "APICall.h"

@interface APIUserMentionStream : APICall
+ (void)getUserMentionStreamWithParameters:(APIPostParameters *)theParameters userID:(NSString *)userID completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler;
@end
