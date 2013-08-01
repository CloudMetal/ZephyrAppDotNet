//
//  UserMentionStreamConfiguration.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "PostStreamConfiguration.h"

@interface UserMentionStreamConfiguration : PostStreamConfiguration
@property (nonatomic) BOOL savesPosts;
@property (nonatomic, copy) NSString *userID;
@end
