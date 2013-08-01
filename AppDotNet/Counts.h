//
//  Counts.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface Counts : NSObject
@property (nonatomic) NSUInteger countOfFollowing;
@property (nonatomic) NSUInteger countOfFollowers;
@property (nonatomic) NSUInteger countOfPosts;

+ (Counts *)countsFromJSONRepresentation:(NSDictionary *)dictionary;
@end
