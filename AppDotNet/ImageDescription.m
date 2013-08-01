//
//  ImageDescription.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ImageDescription.h"

@implementation ImageDescription
+ (ImageDescription *)imageDescriptionFromJSONRepresentation:(NSDictionary *)representation
{
    ImageDescription *imageDescription = [[ImageDescription alloc] init];
    
    imageDescription.width = [[representation objectForKey:@"width"] unsignedIntegerValue];
    imageDescription.height = [[representation objectForKey:@"height"] unsignedIntegerValue];
    imageDescription.url = [NSURL URLWithString:[representation objectForKey:@"url"]];
    
    return imageDescription;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.width = [[coder decodeObjectForKey:@"width"] unsignedIntegerValue];
        self.height = [[coder decodeObjectForKey:@"height"] unsignedIntegerValue];
        self.url = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.width] forKey:@"width"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.height] forKey:@"height"];
    [coder encodeObject:self.url forKey:@"url"];
}
@end
