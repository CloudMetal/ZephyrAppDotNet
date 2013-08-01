//
//  UnregisterForNotificationsCall.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

typedef void (^UnregisterForNotificationsCallback)(BOOL success, NSError *error);

@interface UnregisterForNotificationsCall : NSObject
@property (nonatomic, copy) UnregisterForNotificationsCallback callback;

+ (UnregisterForNotificationsCall *)unregisterForNotificationsWithUserID:(NSString *)theUserID token:(NSString *)theToken userName:(NSString *)theUserName callback:(UnregisterForNotificationsCallback)theCallback;

@end
