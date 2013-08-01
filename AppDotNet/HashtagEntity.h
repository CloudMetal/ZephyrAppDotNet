//
//  HashtagEntity.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface HashtagEntity : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSRange range;

+ (HashtagEntity *)hashtagEntityFromJSONRepresentation:(NSDictionary *)dictionary;
@end
