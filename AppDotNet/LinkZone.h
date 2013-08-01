//
//  LinkZone.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//
#import <Foundation/Foundation.h>

typedef enum {
    LinkZoneTypeUser,
    LinkZoneTypeHashtag,
    LinkZoneTypeLink
} LinkZoneType;

@interface LinkZone : NSObject
@property (nonatomic, copy) NSArray *rects;
@property (nonatomic) LinkZoneType type;
@property (nonatomic) NSString *link;
@end
