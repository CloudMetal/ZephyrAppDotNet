//
//  APIPostParameters.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

extern const NSUInteger APIPostParametersDefaultCountOfPosts;

typedef enum {
    APIPostParameterFlagsNone = 0,
    APIPostParameterFlagsIncludeMuted = 1,
    APIPostParameterFlagsDoNotIncludeMuted = 2,
    APIPostParameterFlagsIncludeDeleted = 4,
    APIPostParameterFlagsDoNotIncludeDeleted = 8,
    APIPostParameterFlagsIncludeDirectedPosts = 16,
    APIPostParameterFlagsDoNotIncludeDirectedPosts = 32,
    APIPostParameterFlagsIncludeUser = 64,
    APIPostParameterFlagsDoNotIncludeUser = 128,
    APIPostParameterFlagsIncludeAnnotations = 256,
    APIPostParameterFlagsDoNotIncludeAnnotations = 512
} APIPostParameterFlags;

@interface APIPostParameters : NSObject
@property (nonatomic, copy) NSString *sinceID;
@property (nonatomic, copy) NSString *beforeID;
@property (nonatomic) NSUInteger countOfPosts;
@property (nonatomic) APIPostParameterFlags flags;

@property (nonatomic, readonly) NSDictionary *parameterDictionary;
@end
