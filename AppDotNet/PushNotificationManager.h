//
//  PushNotificationManager.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APIAuthorizationProfile.h"

@interface PushNotificationManager : NSObject
+ (PushNotificationManager *)sharedPushNotificationManager;

- (void)registerProfileForPushNotifications:(APIAuthorizationProfile *)theProfile;
- (void)unregisterProfileForPushNotifications:(APIAuthorizationProfile *)theProfile;

- (void)applicationRegisteredPushToken:(NSString *)thePushToken isSandbox:(BOOL)isSandbox;
- (void)applicationFailedToRegisterPushToken;
@end
