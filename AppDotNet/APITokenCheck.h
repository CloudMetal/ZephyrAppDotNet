//
//  APITokenCheck.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

@interface APITokenCheck : APICall
+ (void)checkTokenWithCompletionHandler:(void (^)(User *user, NSError *error))theCompletionHandler;
@end
