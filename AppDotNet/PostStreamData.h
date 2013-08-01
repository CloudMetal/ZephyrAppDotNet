//
//  PostStreamData.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "StreamMarker.h"

extern NSString *PostStreamDataDidUpdateNotification;

typedef enum {
    PostStreamElementTypePost,
    PostStreamElementTypeBreakMarker
} PostStreamElementType;

@interface PostStreamData : NSObject <NSCopying>
@property (nonatomic, copy) NSString *currentFocusPostID;
@property (nonatomic, copy) NSString *lastReadPostID;
@property (nonatomic, readonly) NSUInteger countOfElements;
@property (nonatomic, readonly) BOOL hasMorePostsAtEndOfStream;
@property (nonatomic, readonly) NSString *minPostID;
@property (nonatomic, readonly) NSString *maxPostID;
@property (nonatomic, readonly, strong) StreamMarker *streamMarker;

- (void)markPostAsRead:(NSString *)thePostID;

/* This method should only be called for the initial fill of a table */
- (void)setPosts:(NSArray *)theNewPosts hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker;

/* This method should only be called for the "Pull to Refresh" fetch */
- (void)insertPostsToFront:(NSArray *)theNewPosts hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker;

/* This method should be called with the results of a press of the "load more" inner-stream break button */
- (void)insertPosts:(NSArray *)theNewPosts beforeBreakMarkerAtIndex:(NSUInteger)theMarkerIndex hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker;

/* This method should be called with the results of a load more action triggered by scrolling to the end of a table */
- (void)addPostsToEnd:(NSArray *)theNewPosts hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker;

- (PostStreamElementType)elementTypeAtIndex:(NSUInteger)theIndex;
- (Post *)postAtIndex:(NSUInteger)theIndex;

@end
