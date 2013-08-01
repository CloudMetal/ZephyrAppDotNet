//
//  APICall.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APIPostParameters.h"
#import "APIUserParameters.h"
#import "PostListMetadata.h"
#import "UserListMetadata.h"
#import "VDownload.h"
#import "Post.h"

typedef void (^APIPostCallback)(Post *post, NSError *error);
typedef void (^APIPostListCallback)(NSArray *posts, PostListMetadata *meta, NSError *error);
typedef void (^APIUserCallback)(User *user, NSError *error);
typedef void (^APIUserListCallback)(NSArray *posts, UserListMetadata *meta, NSError *error);

typedef enum {
    APICallTypePost,
    APICallTypePostList,
    APICallTypeUser,
    APICallTypeUserList,
    APICallTypeToken,
    APICallTypeStreamMarker
} APICallType;

@interface APICall : NSObject
@property (nonatomic, copy) APIPostListCallback postListCallback;
@property (nonatomic, copy) APIPostCallback postCallback;
@property (nonatomic, copy) APIUserListCallback userListCallback;
@property (nonatomic, copy) APIUserCallback userCallback;

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) NSDictionary *HTTPHeaderFields;
@property (nonatomic, copy) NSData *bodyData;
@property (nonatomic) VDownloadMethod method;

@property (nonatomic) APICallType callType;

- (void)call;
@end
