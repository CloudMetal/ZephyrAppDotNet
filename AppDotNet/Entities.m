//
//  Entities.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Entities.h"

@implementation Entities
+ (Entities *)entitiesWithJSONRepresentation:(NSDictionary *)representation
{
    Entities *entities = [[Entities alloc] init];
    
    NSMutableArray *mentions = [[NSMutableArray alloc] init];
    for(NSDictionary *mention in [representation objectForKey:@"mentions"]) {
        [mentions addObject:[MentionEntity mentionEntityFromJSONRepresentation:mention]];
    }
    entities.mentions = mentions;
    
    NSMutableArray *hashtags = [[NSMutableArray alloc] init];
    for(NSDictionary *hashtag in [representation objectForKey:@"hashtags"]) {
        [hashtags addObject:[HashtagEntity hashtagEntityFromJSONRepresentation:hashtag]];
    }
    entities.hashtags = hashtags;
    
    NSMutableArray *links = [[NSMutableArray alloc] init];
    for(NSDictionary *link in [representation objectForKey:@"links"]) {
        [links addObject:[LinkEntity linkEntityFromJSONRepresentation:link]];
    }
    entities.links = links;
    
    return entities;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.mentions = [coder decodeObjectForKey:@"mentions"];
        self.hashtags = [coder decodeObjectForKey:@"hashtags"];
        self.links = [coder decodeObjectForKey:@"links"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.mentions forKey:@"mentions"];
    [coder encodeObject:self.hashtags forKey:@"hashtags"];
    [coder encodeObject:self.links forKey:@"links"];
}
@end
