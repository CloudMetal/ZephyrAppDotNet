//
//  APIPostParameters.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIPostParameters.h"

const NSUInteger APIPostParametersDefaultCountOfPosts = 20;

@implementation APIPostParameters
- (id)init
{
    self = [super init];
    if(self) {
        self.sinceID = nil;
        self.beforeID = nil;
        self.countOfPosts = APIPostParametersDefaultCountOfPosts;
        self.flags = APIPostParameterFlagsNone;
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
    
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.countOfPosts] forKey:@"count"];
    
    void (^flagSetter)(APIPostParameterFlags, APIPostParameterFlags, NSString *) = ^(APIPostParameterFlags affirmative, APIPostParameterFlags negative, NSString *parameterName) {
        if((self.flags & affirmative) == affirmative) {
            [dictionary setObject:[NSNumber numberWithUnsignedInteger:1] forKey:parameterName];
        } else if((self.flags & negative) == negative) {
            [dictionary setObject:[NSNumber numberWithUnsignedInteger:0] forKey:parameterName];
        }
    };
    
    flagSetter(APIPostParameterFlagsIncludeMuted, APIPostParameterFlagsDoNotIncludeMuted, @"include_muted");
    flagSetter(APIPostParameterFlagsIncludeDeleted, APIPostParameterFlagsDoNotIncludeDeleted, @"include_deleted");
    flagSetter(APIPostParameterFlagsIncludeDirectedPosts, APIPostParameterFlagsDoNotIncludeDirectedPosts, @"include_directed_posts");
    flagSetter(APIPostParameterFlagsIncludeUser, APIPostParameterFlagsDoNotIncludeUser, @"include_user");
    flagSetter(APIPostParameterFlagsIncludeAnnotations, APIPostParameterFlagsDoNotIncludeAnnotations, @"include_annotations");
    
    return dictionary;
}
@end
