//
//  Counts.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Counts.h"

@implementation Counts
+ (Counts *)countsFromJSONRepresentation:(NSDictionary *)dictionary
{
    Counts *counts = [[Counts alloc] init];
    
    counts.countOfFollowing = [[dictionary objectForKey:@"following"] unsignedIntegerValue];
    counts.countOfFollowers = [[dictionary objectForKey:@"followers"] unsignedIntegerValue];
    counts.countOfPosts = [[dictionary objectForKey:@"posts"] unsignedIntegerValue];
    
    return counts;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.countOfFollowing = [[coder decodeObjectForKey:@"following"] unsignedIntegerValue];
        self.countOfFollowers = [[coder decodeObjectForKey:@"followers"] unsignedIntegerValue];
        self.countOfPosts = [[coder decodeObjectForKey:@"posts"] unsignedIntegerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.countOfFollowing] forKey:@"following"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.countOfFollowers] forKey:@"followers"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.countOfPosts] forKey:@"posts"];
}
@end
