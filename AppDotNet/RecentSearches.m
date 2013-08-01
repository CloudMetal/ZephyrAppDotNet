//
//  RecentSearches.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "RecentSearches.h"

@interface RecentSearches() <NSCoding>
@property (nonatomic, copy) NSArray *recentHashtags;

- (NSString *)dataFilePath;

- (void)registerObservers;
- (void)unregisterObservers;

- (void)loadSearches;
- (void)saveSearches;
@end

@implementation RecentSearches
- (NSString *)dataFilePath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [path stringByAppendingPathComponent:@"searches.dat"];
}

+ (RecentSearches *)sharedRecentSearches
{
    static RecentSearches *recentSearchesInstance = nil;
    if(recentSearchesInstance == nil) {
        recentSearchesInstance = [[RecentSearches alloc] init];
    }
    return recentSearchesInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        [self loadSearches];
        
        [self registerObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        self.recentHashtags = [NSArray arrayWithArray:[aDecoder decodeObjectForKey:@"hashtags"]];
        
        [self registerObservers];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if(self.recentHashtags) {
        [aCoder encodeObject:self.recentHashtags forKey:@"hashtags"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"recentHashtags"]) {
        [self saveSearches];
    }
}

#pragma mark -
#pragma mark Public API
- (void)addHashtag:(NSString *)theHashtag
{
    [self removeHashtag:theHashtag];
    
    self.recentHashtags = [[@[theHashtag] arrayByAddingObjectsFromArray:self.recentHashtags] arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
        return theIndex < 10;
    }];
}

- (void)removeHashtag:(NSString *)theHashtag
{
    self.recentHashtags = [self.recentHashtags arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
        return [theHashtag compare:theElement options:NSCaseInsensitiveSearch] != NSOrderedSame;
    }];
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"recentHashtags" options:0 context:0];
}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"recentHashtags"];
}

- (void)loadSearches
{
    self.recentHashtags = [[NSArray alloc] init];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        RecentSearches *searches = [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePath]];
        
        if(searches) {
            self.recentHashtags = searches.recentHashtags;
        }
    }
}

- (void)saveSearches
{
    [NSKeyedArchiver archiveRootObject:self toFile:[self dataFilePath]];
}
@end
