//
//  User.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "UserDescription.h"
#import "ImageDescription.h"
#import "Counts.h"

@interface User : NSObject
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UserDescription *userDescription;
@property (nonatomic, copy) NSTimeZone *timeZone;
@property (nonatomic, copy) NSLocale *locale;
@property (nonatomic, strong) ImageDescription *avatarImage;
@property (nonatomic, strong) ImageDescription *coverImage;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, strong) Counts *counts;
@property (nonatomic) BOOL followsYou;
@property (nonatomic) BOOL youFollow;
@property (nonatomic) BOOL youMuted;

+ (User *)userFromJSONRepresentation:(NSDictionary *)representation;
@end
