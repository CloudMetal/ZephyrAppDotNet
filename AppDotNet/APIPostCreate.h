//
//  APIPostCreate.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIPostCreateDidFinishNotification;

@interface APIPostCreate : APICall
+ (void)createPostWithText:(NSString *)text replyUserID:(NSString *)theReplyUserID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler;
@end
