//
//  PostStreamConfiguration.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "API.h"

typedef enum {
    PostStreamIdiomStream,
    PostStreamIdiomThread,
} PostStreamIdiom;

@interface PostStreamConfiguration : NSObject
@property (nonatomic, readonly) BOOL updatesStreamMarker;
@property (nonatomic, readonly) BOOL shouldOnlyAutoRefreshWhenVisible;
@property (nonatomic, readonly) BOOL savesPosts;
@property (nonatomic, readonly) NSString *savedStreamName;
@property (nonatomic, readonly) PostStreamIdiom idiom;
@property (nonatomic, readonly) void (^apiCallMaker)(APIPostParameters *parameters, APIPostListCallback callback);
@end
