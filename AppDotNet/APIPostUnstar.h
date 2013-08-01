//
//  APIPostUnstar.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

extern NSString *APIPostUnstarDidFinishNotification;

@interface APIPostUnstar : APICall
+ (void)unstarPostWithID:(NSString *)thePostID completionHandler:(void (^)(Post *post, NSError *error))theCompletionHandler;
@end
