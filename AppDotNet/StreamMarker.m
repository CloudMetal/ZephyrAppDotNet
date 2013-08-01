//
//  StreamMarker.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "StreamMarker.h"

@implementation StreamMarker
+ (StreamMarker *)streamMarkerFromJSONRepresentation:(NSDictionary *)representation
{
    StreamMarker *marker = [[StreamMarker alloc] init];
    
    NSDateFormatter *formatter = [[[NSThread currentThread] threadDictionary] objectForKey:@"com.enderlabs.markerdateformatter"];
    if(!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [[[NSThread currentThread] threadDictionary] setObject:formatter forKey:@"com.enderlabs.markerdateformatter"];
    }
    
    marker.postID = [representation objectForKey:@"id"];
    marker.name = [representation objectForKey:@"name"];
    marker.percentage = [[representation objectForKey:@"percentage"] floatValue] / 100.0f;
    marker.updatedAt = [formatter dateFromString:[representation objectForKey:@"updated_at"]];
    marker.version = [representation objectForKey:@"version"];
    
    return marker;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.postID = [coder decodeObjectForKey:@"id"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.percentage = [coder decodeFloatForKey:@"percentage"];
        self.updatedAt = [coder decodeObjectForKey:@"updated_at"];
        self.version = [coder decodeObjectForKey:@"version"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.postID forKey:@"id"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeFloat:self.percentage forKey:@"percentage"];
    [coder encodeObject:self.updatedAt forKey:@"updated_at"];
    [coder encodeObject:self.version forKey:@"version"];
}
@end
