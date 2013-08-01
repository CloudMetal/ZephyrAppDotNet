//
//  MentionEntity.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface MentionEntity : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic) NSRange range;
+ (MentionEntity *)mentionEntityFromJSONRepresentation:(NSDictionary *)dictionary;
@end
