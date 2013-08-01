//
//  HashtagPool.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "HashtagPool.h"

@interface HashtagPool()
@property (nonatomic, strong) NSMutableSet *pool;
@end

@implementation HashtagPool
+ (HashtagPool *)sharedHashtagPool
{
    static HashtagPool *theSharedHashtagPool = nil;
    if(!theSharedHashtagPool) {
        theSharedHashtagPool = [[HashtagPool alloc] init];
    }
    return theSharedHashtagPool;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.pool = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addHashtag:(NSString *)theHashtag
{
    @synchronized(self) {
        [self.pool addObject:theHashtag];
    }
}

- (NSSet *)hashtagsMatching:(NSString *)theString
{
    NSSet *set = nil;
    @synchronized(self) {
        set = [self.pool filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", theString]];
    }
    return set;
}
@end
