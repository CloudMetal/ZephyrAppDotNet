//
//  RecentSearches.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface RecentSearches : NSObject
+ (RecentSearches *)sharedRecentSearches;

@property (nonatomic, readonly, copy) NSArray *recentHashtags;

- (void)addHashtag:(NSString *)theHashtag;
- (void)removeHashtag:(NSString *)theHashtag;
@end
