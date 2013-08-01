//
//  UserSettings.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

#define kSmallFontSize 13.0f
#define kMediumFontSize 15.0f
#define kLargeFontSize 18.0f

#define kPadFontScale 1.1f

#define kRefreshIntervalManual 0.0f
#define kRefreshIntervalFifteenSeconds 15.0f
#define kRefreshIntervalThirtySeconds 30.0f
#define kRefreshIntervalSixtySeconds 60.0f
#define kRefreshIntervalFiveMinutes 300.0f
#define kRefreshIntervalFifteenMinutes 900.0f

#define kRefreshIntervalManualString @"Manual"
#define kRefreshIntervalFifteenSecondsString @"15 Seconds"
#define kRefreshIntervalThirtySecondsString @"30 Seconds"
#define kRefreshIntervalSixtySecondsString @"60 Seconds"
#define kRefreshIntervalFiveMinutesString @"5 Minutes"
#define kRefreshIntervalFifteenMinutesString @"15 Minutes"

typedef enum {
    PhotoServiceSettingYfrog = 0,
    PhotoServiceSettingCloudApp = 1,
} PhotoServiceSetting;

@interface UserSettings : NSObject
@property (nonatomic) BOOL showUserName;
@property (nonatomic) BOOL showDirectedPostsInUserStream;
@property (nonatomic) BOOL showUnifiedStream;
@property (nonatomic, copy) NSString *apnsToken;
@property (nonatomic) BOOL apnsTokenRegisteredInSandbox;
@property (nonatomic) CGFloat bodyFontSize;
@property (nonatomic) NSTimeInterval refreshInterval;
@property (nonatomic) PhotoServiceSetting photoService;

+ (UserSettings *)sharedUserSettings;
@end
