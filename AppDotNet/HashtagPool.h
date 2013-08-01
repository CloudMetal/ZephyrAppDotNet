//
//  HashtagPool.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface HashtagPool : NSObject
+ (HashtagPool *)sharedHashtagPool;

- (void)addHashtag:(NSString *)theHashtag;
- (NSSet *)hashtagsMatching:(NSString *)theString;
@end
