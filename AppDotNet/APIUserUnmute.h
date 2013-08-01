//
//  APIUserUnmute.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIUserUnmuteDidFinishNotification;

@interface APIUserUnmute : APICall
+ (void)unmuteUserWithID:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler;
@end
