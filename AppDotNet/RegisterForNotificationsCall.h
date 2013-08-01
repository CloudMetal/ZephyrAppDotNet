//
//  RegisterForNotificationsCall.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

typedef void (^RegisterForNotificationsCallback)(BOOL success, NSError *error);

@interface RegisterForNotificationsCall : NSObject
@property (nonatomic, copy) RegisterForNotificationsCallback callback;

+ (RegisterForNotificationsCall *)registerForNotificationsWithUserID:(NSString *)theUserID token:(NSString *)theToken userName:(NSString *)theUserName isSandbox:(BOOL)isSandbox callback:(RegisterForNotificationsCallback)theCallback;
@end
