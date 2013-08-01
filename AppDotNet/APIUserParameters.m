//
//  APIUserParameters.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUserParameters.h"

const NSUInteger APIUserParametersDefaultCountOfPosts = 100;

@implementation APIUserParameters
- (id)init
{
    self = [super init];
    if(self) {
        self.sinceID = nil;
        self.beforeID = nil;
        self.countOfUsers = APIUserParametersDefaultCountOfPosts;
    }
    return self;
}

- (NSDictionary *)parameterDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if(self.sinceID) {
        [dictionary setObject:self.sinceID forKey:@"since_id"];
    }
    
    if(self.beforeID) {
        [dictionary setObject:self.beforeID forKey:@"before_id"];
    }
    
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.countOfUsers] forKey:@"count"];
    
    return dictionary;
}
@end
