//
//  UserMentionStreamConfiguration.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserMentionStreamConfiguration.h"

@interface UserMentionStreamConfiguration()
{
    BOOL _savesPosts;
}
@end

@implementation UserMentionStreamConfiguration
- (BOOL)updatesStreamMarker
{
    return _savesPosts;
}

- (BOOL)savesPosts
{
    return _savesPosts;
}

- (void)setSavesPosts:(BOOL)savesPosts
{
    _savesPosts = savesPosts;
}

- (NSString *)savedStreamName
{
    return @"UserMentionStream";
}

- (void (^)(APIPostParameters *parameters, APIPostListCallback callback))apiCallMaker
{
    return [^(APIPostParameters *parameters, APIPostListCallback callback) {
        [APIUserMentionStream getUserMentionStreamWithParameters:parameters userID:self.userID completionHandler:callback];
    } copy];
}
@end
