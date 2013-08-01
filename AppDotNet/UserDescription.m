//
//  UserDescription.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserDescription.h"

@implementation UserDescription
+ (UserDescription *)userDescriptionFromJSONRepresentation:(NSDictionary *)dictionary
{
    UserDescription *userDescription = [[UserDescription alloc] init];
    
    userDescription.text = [dictionary objectForKey:@"text"];
    userDescription.html = [dictionary objectForKey:@"html"];
    userDescription.entities = [Entities entitiesWithJSONRepresentation:[dictionary objectForKey:@"entities"]];
    
    return userDescription;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.text = [coder decodeObjectForKey:@"text"];
        self.html = [coder decodeObjectForKey:@"html"];
        self.entities = [coder decodeObjectForKey:@"entities"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.html forKey:@"html"];
    [coder encodeObject:self.entities forKey:@"entities"];
}
@end
