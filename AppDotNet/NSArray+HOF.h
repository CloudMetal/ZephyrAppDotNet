//
//  NSArray+HOF.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface NSArray (HOF)
- (NSArray *)arrayByFilteringUsingBlock:(BOOL (^)(id theElement, NSUInteger theIndex))theBlock;
- (NSArray *)arrayByMappingBlock:(id (^)(id theElement, NSUInteger theIndex))theBlock;
@end
