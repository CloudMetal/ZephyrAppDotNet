//
//  APIPostRepost.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIPostRepostDidFinishNotification;

@interface APIPostRepost : APICall
+ (void)repostPostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler;
@end
