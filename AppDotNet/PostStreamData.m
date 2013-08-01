//
//  PostStreamData.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostStreamData.h"

NSString *PostStreamDataDidUpdateNotification = @"PostStreamDataDidUpdateNotification";

@interface PostStreamData()
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic) BOOL hasMorePostsAtEndOfStream;
@property (nonatomic, strong) StreamMarker *streamMarker;

- (NSUInteger)indexOfPostWithPostID:(NSString *)thePostID;
@end

@implementation PostStreamData
- (id)copyWithZone:(NSZone *)zone
{
    PostStreamData *copy = [[PostStreamData allocWithZone:zone] init];
    
    copy.elements = [self.elements copy];
    copy.hasMorePostsAtEndOfStream = self.hasMorePostsAtEndOfStream;
    copy.currentFocusPostID = [self.currentFocusPostID copy];
    copy.lastReadPostID = [self.lastReadPostID copy];
    copy.streamMarker = self.streamMarker;
    
    return copy;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.elements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)theCoder
{
    self = [super init];
    if(self) {
        self.elements = [[NSMutableArray alloc] initWithArray:[theCoder decodeObjectForKey:@"elements"]];
        self.hasMorePostsAtEndOfStream = [theCoder decodeBoolForKey:@"hasMorePostsAtEndOfStream"];
        self.currentFocusPostID = [theCoder decodeObjectForKey:@"currentFocusPostID"];
        self.lastReadPostID = [theCoder decodeObjectForKey:@"lastReadPostID"];
        self.streamMarker = [theCoder decodeObjectForKey:@"streamMarker"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)theCoder
{
    [theCoder encodeObject:self.elements forKey:@"elements"];
    [theCoder encodeBool:self.hasMorePostsAtEndOfStream forKey:@"hasMorePostsAtEndOfStream"];
    [theCoder encodeObject:self.currentFocusPostID forKey:@"currentFocusPostID"];
    [theCoder encodeObject:self.lastReadPostID forKey:@"lastReadPostID"];
    [theCoder encodeObject:self.streamMarker forKey:@"streamMarker"];
}

#pragma mark -
#pragma mark Properties
- (NSUInteger)countOfElements
{
    return self.elements.count;
}

- (NSString *)minPostID
{
    for(NSInteger i=self.elements.count - 1; i>=0; i--) {
        if([self elementTypeAtIndex:i] == PostStreamElementTypePost) {
            Post *post = [self postAtIndex:i];
            return post.postID;
        }
    }
    
    return nil;
}

- (NSString *)maxPostID
{
    for(NSUInteger i=0; i<self.elements.count; i++) {
        if([self elementTypeAtIndex:i] == PostStreamElementTypePost) {
            Post *post = [self postAtIndex:i];
            return post.postID;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark Public API

- (void)markPostAsRead:(NSString *)thePostID
{
    if([thePostID longLongValue] > [self.lastReadPostID longLongValue]) {
        self.lastReadPostID = thePostID;
    }
}

- (void)setPosts:(NSArray *)theNewPosts hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker
{
    if([theNewPosts isEqual:self.elements]) {
        return;
    }
    
    [self willChangeValueForKey:@"minPostID"];
    [self willChangeValueForKey:@"maxPostID"];
    [self.elements setArray:theNewPosts];
    self.hasMorePostsAtEndOfStream = hasMore;
    self.streamMarker = theStreamMarker;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PostStreamDataDidUpdateNotification object:self];
    [self didChangeValueForKey:@"minPostID"];
    [self didChangeValueForKey:@"maxPostID"];
    
    if(self.lastReadPostID.longLongValue > self.maxPostID.longLongValue) {
        self.lastReadPostID = self.maxPostID;
    }
}

- (void)insertPostsToFront:(NSArray *)theNewPosts hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker
{
    [self willChangeValueForKey:@"minPostID"];
    [self willChangeValueForKey:@"maxPostID"];
    // Only change the has more flag if the current list is empty
    if(self.elements.count == 0) {
        self.hasMorePostsAtEndOfStream = hasMore;
    }
    
    self.streamMarker = theStreamMarker;
    
    // Cull the list of posts to be no more than 20 after the current focus post
    NSUInteger indexOfCurrentFocusPost = [self indexOfPostWithPostID:self.currentFocusPostID];
    
    if(indexOfCurrentFocusPost == NSNotFound) {
        indexOfCurrentFocusPost = 0;
    }
    
    while(self.elements.count > indexOfCurrentFocusPost + 20) {
        [self.elements removeLastObject];
    }
    
    // Prepare the new array by filling it with the new posts
    NSArray *oldElements = self.elements;
    self.elements = [[NSMutableArray alloc] initWithArray:theNewPosts];
    
    // If there's more posts following the new posts, then we need to insert a
    // break marker
    if(hasMore) {
        [self.elements addObject:[NSNull null]];
    }
    
    // Add the old posts
    [self.elements addObjectsFromArray:oldElements];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PostStreamDataDidUpdateNotification object:self];
    
    [self didChangeValueForKey:@"minPostID"];
    [self didChangeValueForKey:@"maxPostID"];
}

- (void)insertPosts:(NSArray *)theNewPosts beforeBreakMarkerAtIndex:(NSUInteger)theMarkerIndex hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker
{
    [self willChangeValueForKey:@"minPostID"];
    [self willChangeValueForKey:@"maxPostID"];
    NSUInteger insertionIndex = theMarkerIndex;
    for(NSUInteger i=0; i<theNewPosts.count; i++) {
        [self.elements insertObject:[theNewPosts objectAtIndex:i] atIndex:insertionIndex];
        insertionIndex++;
    }
    
    if(!hasMore) {
        [self.elements removeObjectAtIndex:insertionIndex];
    }
    
    self.streamMarker = theStreamMarker;

    [[NSNotificationCenter defaultCenter] postNotificationName:PostStreamDataDidUpdateNotification object:self];
    
    [self didChangeValueForKey:@"minPostID"];
    [self didChangeValueForKey:@"maxPostID"];
}

- (void)addPostsToEnd:(NSArray *)theNewPosts hasMore:(BOOL)hasMore marker:(StreamMarker *)theStreamMarker
{
    [self willChangeValueForKey:@"minPostID"];
    [self willChangeValueForKey:@"maxPostID"];
    [self.elements addObjectsFromArray:theNewPosts];
    
    self.hasMorePostsAtEndOfStream = hasMore;
    self.streamMarker = theStreamMarker;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PostStreamDataDidUpdateNotification object:self];
    
    [self didChangeValueForKey:@"minPostID"];
    [self didChangeValueForKey:@"maxPostID"];
}

- (PostStreamElementType)elementTypeAtIndex:(NSUInteger)theIndex
{
    NSAssert(theIndex < self.countOfElements, @"Element index out of bounds");
    
    if([self.elements objectAtIndex:theIndex] == [NSNull null]) {
        return PostStreamElementTypeBreakMarker;
    }
    
    return PostStreamElementTypePost;
}

- (Post *)postAtIndex:(NSUInteger)theIndex
{
    NSAssert(theIndex < self.countOfElements, @"Post index out of bounds");
    NSAssert([self elementTypeAtIndex:theIndex] == PostStreamElementTypePost, @"Attempt to access post from a break marker");
    
    return [self.elements objectAtIndex:theIndex];
}

#pragma mark -
#pragma mark Private API
- (NSUInteger)indexOfPostWithPostID:(NSString *)thePostID
{
    if(thePostID == nil) {
        return NSNotFound;
    }
    
    for(NSUInteger i=0; i<self.elements.count; i++) {
        if([self elementTypeAtIndex:i] == PostStreamElementTypePost) {
            Post *post = [self postAtIndex:i];
            if([post.postID isEqual:thePostID]) {
                return i;
            }
        }
    }
    
    return NSNotFound;
}
@end
