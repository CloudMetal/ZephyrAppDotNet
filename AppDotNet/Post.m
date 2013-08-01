//
//  Post.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Post.h"

@implementation Post
+ (Post *)postFromJSONRepresentation:(NSDictionary *)representation
{
    Post *post = [[Post alloc] init];
    
    NSDateFormatter *formatter = [[[NSThread currentThread] threadDictionary] objectForKey:@"com.enderlabs.postdateformatter"];
    if(!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [[[NSThread currentThread] threadDictionary] setObject:formatter forKey:@"com.enderlabs.postdateformatter"];
    }
    
    post.postID = [representation objectForKey:@"id"];
    NSDictionary *userDictionary = [representation objectForKey:@"user"];
    if(userDictionary) {
        NSMutableDictionary *userIDCache =[[[NSThread currentThread] threadDictionary] objectForKey:@"com.enderlabs.useridcache"];
        post.user = [userIDCache objectForKey:[userDictionary objectForKey:@"id"]];
        if(!post.user) {
            post.user = [User userFromJSONRepresentation:userDictionary];
            [userIDCache setObject:post.user forKey:[userDictionary objectForKey:@"id"]];
        }
    }
    post.createdAt = [formatter dateFromString:[representation objectForKey:@"created_at"]];
    post.text = [representation objectForKey:@"text"];
    post.html = [representation objectForKey:@"html"];
    post.postSource = [PostSource postSourceFromJSONRepresentation:[representation objectForKey:@"source"]];
    post.replyTo = [representation objectForKey:@"reply_to"];
    post.threadID = [representation objectForKey:@"thread_id"];
    post.countOfReplies = [[representation objectForKey:@"num_replies"] unsignedIntegerValue];
    post.annotations = [representation objectForKey:@"annotations"];
    post.entities = [Entities entitiesWithJSONRepresentation:[representation objectForKey:@"entities"]];
    post.isDeleted = [[representation objectForKey:@"is_deleted"] boolValue];
    post.youReposted = [[representation objectForKey:@"you_reposted"] boolValue];
    post.youStarred = [[representation objectForKey:@"you_starred"] boolValue];
    
    if([representation objectForKey:@"repost_of"]) {
        post.repostOf = [Post postFromJSONRepresentation:[representation objectForKey:@"repost_of"]];
    }
    
    // Adjust entity ranges for surrogates
    [post.text enumerateSubstringsInRange:NSMakeRange(0, post.text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        unichar textCharacter = [substring characterAtIndex:0];
        if(0xd800 <= textCharacter && textCharacter <= 0xdbff) {
            for(HashtagEntity *hashtag in post.entities.hashtags) {
                if(hashtag.range.location > substringRange.location) {
                    hashtag.range = NSMakeRange(hashtag.range.location + 1, hashtag.range.length);
                } else if(hashtag.range.location + hashtag.range.length > substringRange.location) {
                    hashtag.range = NSMakeRange(hashtag.range.location, hashtag.range.length + 1);
                }
            }
            for(LinkEntity *link in post.entities.links) {
                if(link.range.location > substringRange.location) {
                    link.range = NSMakeRange(link.range.location + 1, link.range.length);
                } else if(link.range.location + link.range.length > substringRange.location) {
                    link.range = NSMakeRange(link.range.location, link.range.length + 1);
                }
            }
            for(MentionEntity *mention in post.entities.mentions) {
                if(mention.range.location > substringRange.location) {
                    mention.range = NSMakeRange(mention.range.location + 1, mention.range.length);
                } else if(mention.range.location + mention.range.length > substringRange.location) {
                    mention.range = NSMakeRange(mention.range.location, mention.range.length + 1);
                }
            }
        }
    }];
    
    return post;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.postID = [coder decodeObjectForKey:@"id"];
        self.user = [coder decodeObjectForKey:@"user"];
        self.createdAt = [coder decodeObjectForKey:@"created_at"];
        self.text = [coder decodeObjectForKey:@"text"];
        self.html = [coder decodeObjectForKey:@"html"];
        self.postSource = [coder decodeObjectForKey:@"source"];
        self.replyTo = [coder decodeObjectForKey:@"reply_to"];
        self.threadID = [coder decodeObjectForKey:@"thread_id"];
        self.countOfReplies = [[coder decodeObjectForKey:@"num_replies"] unsignedIntegerValue];
        self.annotations = [coder decodeObjectForKey:@"annotations"];
        self.entities = [coder decodeObjectForKey:@"entities"];
        self.isDeleted = [[coder decodeObjectForKey:@"is_deleted"] boolValue];
        self.youReposted = [[coder decodeObjectForKey:@"you_reposted"] boolValue];
        self.youStarred = [[coder decodeObjectForKey:@"you_starred"] boolValue];
        self.repostOf = [coder decodeObjectForKey:@"repost_of"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.postID forKey:@"id"];
    [coder encodeObject:self.user forKey:@"user"];
    [coder encodeObject:self.createdAt forKey:@"created_at"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.html forKey:@"html"];
    [coder encodeObject:self.postSource forKey:@"source"];
    [coder encodeObject:self.replyTo forKey:@"reply_to"];
    [coder encodeObject:self.threadID forKey:@"thread_id"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.countOfReplies] forKey:@"num_replies"];
    [coder encodeObject:self.annotations forKey:@"annotations"];
    [coder encodeObject:self.entities forKey:@"entities"];
    [coder encodeObject:[NSNumber numberWithBool:self.isDeleted] forKey:@"is_deleted"];
    [coder encodeObject:[NSNumber numberWithBool:self.youReposted] forKey:@"you_reposted"];
    [coder encodeObject:[NSNumber numberWithBool:self.youStarred] forKey:@"you_starred"];
    [coder encodeObject:self.repostOf forKey:@"repost_of"];
}
@end
