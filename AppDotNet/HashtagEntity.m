//
//  HashtagEntity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "HashtagEntity.h"
#import "HashtagPool.h"

@implementation HashtagEntity
+ (HashtagEntity *)hashtagEntityFromJSONRepresentation:(NSDictionary *)dictionary
{
    HashtagEntity *hashtagEntity = [[HashtagEntity alloc] init];
    
    hashtagEntity.name = [dictionary objectForKey:@"name"];
    hashtagEntity.range = NSMakeRange([[dictionary objectForKey:@"pos"] unsignedIntegerValue], [[dictionary objectForKey:@"len"] unsignedIntegerValue]);
    
    [[HashtagPool sharedHashtagPool] addHashtag:hashtagEntity.name];
    
    return hashtagEntity;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.range = [[coder decodeObjectForKey:@"range"] rangeValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
}
@end
