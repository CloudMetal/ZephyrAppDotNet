//
//  LinkEntity.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "LinkEntity.h"

@implementation LinkEntity
+ (LinkEntity *)linkEntityFromJSONRepresentation:(NSDictionary *)representation
{
    LinkEntity *linkEntity = [[LinkEntity alloc] init];
    
    linkEntity.text = [representation objectForKey:@"text"];
    linkEntity.url = [NSURL URLWithString:[representation objectForKey:@"url"]];
    linkEntity.range = NSMakeRange([[representation objectForKey:@"pos"] unsignedIntegerValue], [[representation objectForKey:@"len"] unsignedIntegerValue]);
    
    return linkEntity;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.text = [coder decodeObjectForKey:@"text"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.range = [[coder decodeObjectForKey:@"range"] rangeValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
}
@end
