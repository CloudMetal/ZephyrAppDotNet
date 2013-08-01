//
//  APIAuthorizationProfile.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

extern NSString *APIAuthorizationProfileDidChangeNotification;

@interface APIAuthorizationProfile : NSObject <NSCoding>
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSURL *localAvatarURL;
@property (nonatomic) BOOL authorizedForPushNotifications;
@end
