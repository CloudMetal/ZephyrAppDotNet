//
//  Entities.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "MentionEntity.h"
#import "HashtagEntity.h"
#import "LinkEntity.h"

@interface Entities : NSObject
@property (nonatomic, copy) NSArray *mentions;
@property (nonatomic, copy) NSArray *hashtags;
@property (nonatomic, copy) NSArray *links;

+ (Entities *)entitiesWithJSONRepresentation:(NSDictionary *)representation;
@end
