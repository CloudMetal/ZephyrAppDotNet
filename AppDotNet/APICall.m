//
//  APICall.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APICall.h"
#import "APIAuthorization.h"
#import "APIError.h"

static NSMutableArray *calls = nil;

@interface APICall() <VDownloadDelegate>
@property (nonatomic, strong) VDownload *download;
@end

@implementation APICall
- (void)call
{
    if(!calls) {
        calls = [[NSMutableArray alloc] init];
    }
    
    [calls addObject:self];
    
    self.download = [[VDownload alloc] init];
    self.download.url = self.url;
    self.download.parameters = self.parameters;
    self.download.method = self.method;
    self.download.delegate = self;
    self.download.bodyData = self.bodyData;
    
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"Bearer %@", [[APIAuthorization sharedAPIAuthorization] currentProfile].accessToken] forKey:@"Authorization"];
    if(self.HTTPHeaderFields) {
        [headerFields addEntriesFromDictionary:self.HTTPHeaderFields];
    }
    
    self.download.HTTPHeaderFields = headerFields;
    [self.download start];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:theData options:0 error:0];
        if([data objectForKey:@"error"] && ![[[data objectForKey:@"error"] objectForKey:@"code"] isEqual:[NSNumber numberWithInt:404]]) {
            NSLog(@"%@", [data objectForKey:@"error"]);
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      APIErrorNotAuthenticatedDescription, NSLocalizedDescriptionKey,
                                      APIErrorNotAuthenticatedReason, NSLocalizedFailureReasonErrorKey,
                                      nil];
            
            NSError *error = [NSError errorWithDomain:APIErrorDomain code:APIErrorNotAuthenticated userInfo:userInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APIAuthorization sharedAPIAuthorization] removeProfile:[[APIAuthorization sharedAPIAuthorization] currentProfile]];
                [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:nil];
                
                [calls removeObject:self];
                switch (self.callType) {
                    case APICallTypePost:
                        self.postCallback(nil, error);
                        break;
                    case APICallTypePostList:
                        self.postListCallback(nil, nil, error);
                        break;
                    case APICallTypeUser:
                        self.userCallback(nil, error);
                        break;
                    case APICallTypeUserList:
                        self.userListCallback(nil, nil, error);
                        break;
                    case APICallTypeToken:
                        self.userCallback(nil, error);
                        break;
                    case APICallTypeStreamMarker:
                        break;
                    default:
                        break;
                }
            });
        } else {
            if(self.callType == APICallTypePost) {
                Post *post = [Post postFromJSONRepresentation:[data objectForKey:@"data"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [calls removeObject:self];
                    self.postCallback(post, nil);
                });
            } else if(self.callType == APICallTypePostList) {
                NSMutableArray *processedPosts = [[NSMutableArray alloc] init];
                NSArray *posts = [data objectForKey:@"data"];
                [[[NSThread currentThread] threadDictionary] setObject:[NSMutableDictionary dictionary] forKey:@"com.enderlabs.useridcache"];
                for(NSDictionary *post in posts) {
                    @autoreleasepool {
                        [processedPosts addObject:[Post postFromJSONRepresentation:post]];
                    }
                }
                
                NSArray *packagedPosts = [[NSArray alloc] initWithArray:processedPosts];
                PostListMetadata *meta = [PostListMetadata postListMetadataFromJSONRepresentation:[data objectForKey:@"meta"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [calls removeObject:self];
                    self.postListCallback(packagedPosts, meta, nil);
                });
            } else if(self.callType == APICallTypeUser) {
                User *user = [User userFromJSONRepresentation:[data objectForKey:@"data"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [calls removeObject:self];
                    self.userCallback(user, nil);
                });
            } else if(self.callType == APICallTypeUserList) {
                NSMutableArray *processedUsers = [[NSMutableArray alloc] init];
                NSArray *users = [data objectForKey:@"data"];
                [[[NSThread currentThread] threadDictionary] setObject:[NSMutableDictionary dictionary] forKey:@"com.enderlabs.useridcache"];
                for(NSDictionary *user in users) {
                    @autoreleasepool {
                        [processedUsers addObject:[User userFromJSONRepresentation:user]];
                    }
                }
                
                NSArray *packagedUsers = [[NSArray alloc] initWithArray:processedUsers];
                UserListMetadata *meta = [UserListMetadata userListMetadataFromJSONRepresentation:[data objectForKey:@"meta"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [calls removeObject:self];
                    self.userListCallback(packagedUsers, meta, nil);
                });
            } else if(self.callType == APICallTypeToken) {
                User *user = [User userFromJSONRepresentation:[[data objectForKey:@"data"] objectForKey:@"user"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [calls removeObject:self];
                    self.userCallback(user, nil);
                });
            } else if(self.callType == APICallTypeStreamMarker) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [calls removeObject:self];
                });
            }
        }
    });
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    [calls removeObject:self];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              APIErrorCommunicationsErrorDescription, NSLocalizedDescriptionKey,
                              APIErrorCommunicationsErrorReason, NSLocalizedFailureReasonErrorKey,
                              nil];
    
    NSError *error = [NSError errorWithDomain:APIErrorDomain code:APIErrorCommunicationsError userInfo:userInfo];
    switch (self.callType) {
        case APICallTypePost:
            self.postCallback(nil, error);
            break;
        case APICallTypePostList:
            self.postListCallback(nil, nil, error);
            break;
        case APICallTypeUser:
            self.userCallback(nil, error);
            break;
        case APICallTypeUserList:
            self.userListCallback(nil, nil, error);
            break;
        case APICallTypeToken:
            self.userCallback(nil, error);
            break;
        case APICallTypeStreamMarker:
            break;
        default:
            break;
    }
}
@end
