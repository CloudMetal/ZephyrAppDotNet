//
//  PushNotificationManager.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PushNotificationManager.h"
#import "APIAuthorization.h"
#import "RegisterForNotificationsCall.h"
#import "UnregisterForNotificationsCall.h"

@interface PushNotificationManager()
@property (nonatomic, strong) NSMutableArray *registerProfileQueue;
@end

@implementation PushNotificationManager
+ (PushNotificationManager *)sharedPushNotificationManager
{
    static PushNotificationManager *sharedPushNotificationManagerInstance = nil;
    if(sharedPushNotificationManagerInstance == nil) {
        sharedPushNotificationManagerInstance = [[PushNotificationManager alloc] init];
    }
    return sharedPushNotificationManagerInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.registerProfileQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)registerProfileForPushNotifications:(APIAuthorizationProfile *)theProfile
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"PNMPushToken"]) {
        [RegisterForNotificationsCall registerForNotificationsWithUserID:theProfile.userID
                                                                   token:[[NSUserDefaults standardUserDefaults] objectForKey:@"PNMPushToken"]
                                                                userName:theProfile.userName
                                                               isSandbox:[[[NSUserDefaults standardUserDefaults] objectForKey:@"PNMIsSandbox"] boolValue]
                                                                callback:^(BOOL success, NSError *error) {
                                                                    theProfile.authorizedForPushNotifications = success;
                                                                }];
    } else {
        [self.registerProfileQueue addObject:theProfile];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
}

- (void)unregisterProfileForPushNotifications:(APIAuthorizationProfile *)theProfile
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"PNMPushToken"] == nil) {
        theProfile.authorizedForPushNotifications = NO;
        return;
    }
    
    [UnregisterForNotificationsCall unregisterForNotificationsWithUserID:theProfile.userID
                                                                   token:[[NSUserDefaults standardUserDefaults] objectForKey:@"PNMPushToken"]
                                                                userName:theProfile.userName
                                                                callback:^(BOOL success, NSError *error) {
                                                                    if(success) {
                                                                        theProfile.authorizedForPushNotifications = NO;
                                                                    }
                                                                }];
    
    return;
}

- (void)applicationRegisteredPushToken:(NSString *)thePushToken isSandbox:(BOOL)isSandbox
{
    [[NSUserDefaults standardUserDefaults] setObject:thePushToken forKey:@"PNMPushToken"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isSandbox] forKey:@"PNMIsSandbox"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for(APIAuthorizationProfile *profile in self.registerProfileQueue) {
        [self registerProfileForPushNotifications:profile];
    }
    
    [self.registerProfileQueue removeAllObjects];
}

- (void)applicationFailedToRegisterPushToken
{
    for(APIAuthorizationProfile *profile in [[APIAuthorization sharedAPIAuthorization] profiles]) {
        [self unregisterProfileForPushNotifications:profile];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PNMPushToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PNMIsSandbox"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
