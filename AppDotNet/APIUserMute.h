//
//  APIUserMute.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIUserMuteDidFinishNotification;

@interface APIUserMute : APICall
+ (void)muteUserWithID:(NSString *)theUserID completionHandler:(void (^)(User *user, NSError *error))theCompletionHandler;
@end
