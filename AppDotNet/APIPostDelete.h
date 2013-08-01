//
//  APIPostDelete.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIPostDeleteDidFinishNotification;

@interface APIPostDelete : APICall
+ (void)deletePostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler;
@end
