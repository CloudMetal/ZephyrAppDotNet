//
//  APIAuthorizationProfile.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIAuthorizationProfile.h"

NSString *APIAuthorizationProfileDidChangeNotification = @"APIAuthorizationProfileDidChangeNotification";

@interface APIAuthorizationProfile()
- (void)registerObservers;
- (void)unregisterObservers;
@end

@implementation APIAuthorizationProfile
- (id)init
{
    self = [super init];
    if(self) {
        [self registerObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        self.accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
        self.user = [aDecoder decodeObjectForKey:@"user"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.localAvatarURL = [aDecoder decodeObjectForKey:@"localAvatarURL"];
        self.authorizedForPushNotifications = [aDecoder decodeBoolForKey:@"authorizedForPushNotifications"];
        
        [self registerObservers];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
    [aCoder encodeObject:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.user forKey:@"user"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.localAvatarURL forKey:@"localAvatarURL"];
    [aCoder encodeBool:self.authorizedForPushNotifications forKey:@"authorizedForPushNotifications"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"accessToken"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationProfileDidChangeNotification object:self];
    } else if([keyPath isEqualToString:@"userID"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationProfileDidChangeNotification object:self];
    } else if([keyPath isEqualToString:@"user"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationProfileDidChangeNotification object:self];
    } else if([keyPath isEqualToString:@"userName"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationProfileDidChangeNotification object:self];
    } else if([keyPath isEqualToString:@"localAvatarURL"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationProfileDidChangeNotification object:self];
    } else if([keyPath isEqualToString:@"authorizedForPushNotifications"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationProfileDidChangeNotification object:self];
    }
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"accessToken" options:0 context:0];
    [self addObserver:self forKeyPath:@"userID" options:0 context:0];
    [self addObserver:self forKeyPath:@"user" options:0 context:0];
    [self addObserver:self forKeyPath:@"userName" options:0 context:0];
    [self addObserver:self forKeyPath:@"localAvatarURL" options:0 context:0];
    [self addObserver:self forKeyPath:@"authorizedForPushNotifications" options:0 context:0];
}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"accessToken"];
    [self removeObserver:self forKeyPath:@"userID"];
    [self removeObserver:self forKeyPath:@"user"];
    [self removeObserver:self forKeyPath:@"userName"];
    [self removeObserver:self forKeyPath:@"localAvatarURL"];
    [self removeObserver:self forKeyPath:@"authorizedForPushNotifications"];
}
@end
