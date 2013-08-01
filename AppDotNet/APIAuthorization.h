//
//  APIAuthorization.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APIAuthorizationProfile.h"

extern NSString *APIAuthorizationAccessTokenDidChangeNotification;

@interface APIAuthorization : NSObject
+ (APIAuthorization *)sharedAPIAuthorization;

@property (nonatomic, readonly, copy) NSArray *profiles;
@property (nonatomic, strong) APIAuthorizationProfile *currentProfile;

- (void)addProfileWithAccessToken:(NSString *)theAccessToken;
- (void)removeProfile:(APIAuthorizationProfile *)theProfile;

- (void)setImage:(UIImage *)image forProfile:(APIAuthorizationProfile *)theProfile;
- (UIImage *)imageForProfile:(APIAuthorizationProfile *)theProfile;
@end
