//
//  UserDescription.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "Entities.h"

@interface UserDescription : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, strong) Entities *entities;

+ (UserDescription *)userDescriptionFromJSONRepresentation:(NSDictionary *)dictionary;
@end
