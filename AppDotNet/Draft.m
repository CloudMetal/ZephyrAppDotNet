//
//  Draft.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Draft.h"

@implementation Draft
- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if(self) {
        self.replyToID = [coder decodeObjectForKey:@"replyToID"];
        self.replyText = [coder decodeObjectForKey:@"replyText"];
        self.text = [coder decodeObjectForKey:@"text"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.replyToID forKey:@"replyToID"];
    [coder encodeObject:self.replyText forKey:@"replyText"];
    [coder encodeObject:self.text forKey:@"text"];
}
@end
