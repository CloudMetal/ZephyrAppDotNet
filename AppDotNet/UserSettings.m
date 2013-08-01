//
//  UserSettings.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserSettings.h"
#import "VDownload.h"
#import "AuthenticatedUser.h"

@interface UserSettings() <VDownloadDelegate>
@property (nonatomic, strong) NSMutableArray *downloads;

- (void)submitPushRegistration;
- (void)submitPushDeregistration;
@end

@implementation UserSettings
+ (UserSettings *)sharedUserSettings
{
    static UserSettings *sharedUserSettingsInstance = nil;
    if(!sharedUserSettingsInstance) {
        sharedUserSettingsInstance = [[UserSettings alloc] init];
    }
    return sharedUserSettingsInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.downloads = [[NSMutableArray alloc] init];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [NSNumber numberWithFloat:kMediumFontSize], @"UserSettingsBodyFontSize",
                                                                 [NSNumber numberWithBool:YES], @"UserSettingsShowUnifiedStream",
                                                                 nil]];
        
        self.bodyFontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:@"UserSettingsBodyFontSize"];
        self.showUserName = [[NSUserDefaults standardUserDefaults] boolForKey:@"UserSettingsShowUserName"];
        self.showUnifiedStream = [[NSUserDefaults standardUserDefaults] boolForKey:@"UserSettingsShowUnifiedStream"];
        self.showDirectedPostsInUserStream = [[NSUserDefaults standardUserDefaults] boolForKey:@"UserSettingsShowDirectedPostsInUserStream"];
        self.apnsTokenRegisteredInSandbox = [[NSUserDefaults standardUserDefaults] boolForKey:@"UserSettingsAPNSSandbox"];
        self.apnsToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserSettingsAPNSToken"];
        self.refreshInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"UserSettingsRefreshInterval"];
        self.photoService = [[NSUserDefaults standardUserDefaults] integerForKey:@"UserSettingsPhotoService"];
        
        if(self.apnsToken) {
            if(self.apnsTokenRegisteredInSandbox && ![[UIApplication sharedApplication] isSandboxed]) {
                self.apnsToken = nil;
            } else if(!self.apnsTokenRegisteredInSandbox && [[UIApplication sharedApplication] isSandboxed]) {
                self.apnsToken = nil;
            }
        }
        
        [self addObserver:self forKeyPath:@"bodyFontSize" options:0 context:0];
        [self addObserver:self forKeyPath:@"showUserName" options:0 context:0];
        [self addObserver:self forKeyPath:@"showUnifiedStream" options:0 context:0];
        [self addObserver:self forKeyPath:@"showDirectedPostsInUserStream" options:0 context:0];
        [self addObserver:self forKeyPath:@"apnsTokenRegisteredInSandbox" options:0 context:0];
        [self addObserver:self forKeyPath:@"apnsToken" options:0 context:0];
        [self addObserver:self forKeyPath:@"refreshInterval" options:0 context:0];
        [self addObserver:self forKeyPath:@"photoService" options:0 context:0];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"showUserName"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showUserName forKey:@"UserSettingsShowUserName"];
    } else if([keyPath isEqualToString:@"showUnifiedStream"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showUnifiedStream forKey:@"UserSettingsShowUnifiedStream"];
    } else if([keyPath isEqualToString:@"showDirectedPostsInUserStream"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showDirectedPostsInUserStream forKey:@"UserSettingsShowDirectedPostsInUserStream"];
    } else if([keyPath isEqualToString:@"apnsTokenRegisteredInSandbox"]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.apnsTokenRegisteredInSandbox forKey:@"UserSettingsAPNSSandbox"];
    } else if([keyPath isEqualToString:@"apnsToken"]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.apnsToken forKey:@"UserSettingsAPNSToken"];
        
        if(self.apnsToken) {
            [self submitPushRegistration];
        } else if(!self.apnsToken) {
            [self submitPushDeregistration];
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        }
    } else if([keyPath isEqualToString:@"bodyFontSize"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:self.bodyFontSize forKey:@"UserSettingsBodyFontSize"];
    } else if([keyPath isEqualToString:@"refreshInterval"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:self.refreshInterval forKey:@"UserSettingsRefreshInterval"];
    } else if([keyPath isEqualToString:@"photoService"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.photoService forKey:@"UserSettingsPhotoService"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Private API
- (void)submitPushRegistration
{
    if(KeyFiberAppServiceKey) {
        VDownload *download = [[VDownload alloc] init];
        
        download.url = [NSURL URLWithString:@"http://push.fiberapp.net/api/devices/register"];
        download.method = VDownloadMethodPOST;
        download.parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[[AuthenticatedUser sharedAuthenticatedUser] user] userName], @"username",
                               [[[AuthenticatedUser sharedAuthenticatedUser] user] userID], @"user_id",
                               self.apnsToken, @"apns_token",
                               KeyFiberAppServiceKey, @"service_key",
                               nil];
        download.delegate = self;
        
        [self.downloads addObject:download];
        
        [download start];
    } else {
        NSLog(@"No fiber app service key, cannot register for push notifications.");
    }
}

- (void)submitPushDeregistration
{
    
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    [self.downloads removeObject:theDownload];
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    [self.downloads removeObject:theDownload];
}
@end
