//
//  User.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "User.h"
#import "UsernamePool.h"

@implementation User
+ (User *)userFromJSONRepresentation:(NSDictionary *)representation
{
    User *user = [[User alloc] init];
    
    NSDateFormatter *formatter = [[[NSThread currentThread] threadDictionary] objectForKey:@"com.enderlabs.userdateformatter"];
    if(!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [[[NSThread currentThread] threadDictionary] setObject:formatter forKey:@"com.enderlabs.userdateformatter"];
    }
    
    user.userID = [representation objectForKey:@"id"];
    user.userName = [representation objectForKey:@"username"];
    user.name = [representation objectForKey:@"name"];
    user.userDescription = [UserDescription userDescriptionFromJSONRepresentation:[representation objectForKey:@"description"]];
    user.timeZone = [NSTimeZone timeZoneWithName:[representation objectForKey:@"timezone"]];
    user.locale = [[NSLocale alloc] initWithLocaleIdentifier:[representation objectForKey:@"locale"]];
    user.avatarImage = [ImageDescription imageDescriptionFromJSONRepresentation:[representation objectForKey:@"avatar_image"]];
    user.coverImage = [ImageDescription imageDescriptionFromJSONRepresentation:[representation objectForKey:@"cover_image"]];
    user.type = [representation objectForKey:@"type"];
    user.createdAt = [formatter dateFromString:[representation objectForKey:@"created_at"]];
    user.counts = [Counts countsFromJSONRepresentation:[representation objectForKey:@"counts"]];
    user.followsYou = [[representation objectForKey:@"follows_you"] boolValue];
    user.youFollow = [[representation objectForKey:@"you_follow"] boolValue];
    user.youMuted = [[representation objectForKey:@"you_muted"] boolValue];
    
    [[UsernamePool sharedUsernamePool] addUsername:user.userName name:user.name];
    
    return user;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.userID = [coder decodeObjectForKey:@"id"];
        self.userName = [coder decodeObjectForKey:@"username"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.userDescription = [coder decodeObjectForKey:@"description"];
        self.timeZone = [coder decodeObjectForKey:@"timezone"];
        self.locale = [coder decodeObjectForKey:@"locale"];
        self.avatarImage = [coder decodeObjectForKey:@"avatar_image"];
        self.coverImage = [coder decodeObjectForKey:@"cover_image"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.createdAt = [coder decodeObjectForKey:@"created_at"];
        self.counts = [coder decodeObjectForKey:@"counts"];
        self.followsYou = [[coder decodeObjectForKey:@"follows_you"] boolValue];
        self.youFollow = [[coder decodeObjectForKey:@"you_follow"] boolValue];
        self.youMuted = [[coder decodeObjectForKey:@"you_muted"] boolValue];
        
        [[UsernamePool sharedUsernamePool] addUsername:self.userName name:self.name];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.userID forKey:@"id"];
    [coder encodeObject:self.userName forKey:@"username"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.userDescription forKey:@"description"];
    [coder encodeObject:self.timeZone forKey:@"timezone"];
    [coder encodeObject:self.locale forKey:@"locale"];
    [coder encodeObject:self.avatarImage forKey:@"avatar_image"];
    [coder encodeObject:self.coverImage forKey:@"cover_image"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.createdAt forKey:@"created_at"];
    [coder encodeObject:self.counts forKey:@"counts"];
    [coder encodeObject:[NSNumber numberWithBool:self.followsYou] forKey:@"follows_you"];
    [coder encodeObject:[NSNumber numberWithBool:self.youFollow] forKey:@"you_follow"];
    [coder encodeObject:[NSNumber numberWithBool:self.youMuted] forKey:@"you_muted"];
}
@end
