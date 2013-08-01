//
//  PostSource.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostSource.h"

@implementation PostSource
+ (PostSource *)postSourceFromJSONRepresentation:(NSDictionary *)representation
{
    PostSource *postSource = [[PostSource alloc] init];
    
    postSource.name = [representation objectForKey:@"name"];
    postSource.link = [NSURL URLWithString:[representation objectForKey:@"link"]];
    
    return postSource;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.link = [coder decodeObjectForKey:@"link"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.link forKey:@"link"];
}
@end
