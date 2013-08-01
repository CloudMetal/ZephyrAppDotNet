//
//  APIGlobalPostStream.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

@interface APIGlobalPostStream : APICall
+ (void)getGlobalPostStreamWithParameters:(APIPostParameters *)theParameters completionHandler:(void (^)(NSArray *posts, PostListMetadata *meta, NSError *error))theCompletionHandler;
@end
