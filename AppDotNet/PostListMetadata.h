//
//  PostListMetadata.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "StreamMarker.h"

@interface PostListMetadata : NSObject
@property (nonatomic, copy) NSString *maxID;
@property (nonatomic, copy) NSString *minID;
@property (nonatomic) BOOL hasMore;
@property (nonatomic, strong) StreamMarker *streamMarker;

+ (PostListMetadata *)postListMetadataFromJSONRepresentation:(NSDictionary *)representation;
@end
