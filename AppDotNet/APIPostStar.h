//
//  APIPostStar.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIPostStarDidFinishNotification;

@interface APIPostStar : APICall
+ (void)starPostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler;
@end
