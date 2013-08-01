//
//  MentionEntity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "MentionEntity.h"
#import "UsernamePool.h"

@implementation MentionEntity
+ (MentionEntity *)mentionEntityFromJSONRepresentation:(NSDictionary *)dictionary
{
    MentionEntity *mentionEntity = [[MentionEntity alloc] init];
    
    mentionEntity.name = [dictionary objectForKey:@"name"];
    mentionEntity.userID = [dictionary objectForKey:@"id"];
    mentionEntity.range = NSMakeRange([[dictionary objectForKey:@"pos"] unsignedIntegerValue], [[dictionary objectForKey:@"len"] unsignedIntegerValue]);
    
    [[UsernamePool sharedUsernamePool] addUsername:mentionEntity.name name:nil];
    
    return mentionEntity;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.userID = [coder decodeObjectForKey:@"id"];
        self.range = [[coder decodeObjectForKey:@"range"] rangeValue];
        
        [[UsernamePool sharedUsernamePool] addUsername:self.name name:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.userID forKey:@"id"];
    [coder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
}
@end
