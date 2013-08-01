//
//  NSArray+HOF.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "NSArray+HOF.h"

@implementation NSArray (HOF)
- (NSArray *)arrayByFilteringUsingBlock:(BOOL (^)(id theElement, NSUInteger theIndex))theBlock
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(theBlock(obj, idx)) {
            [newArray addObject:obj];
        }
    }];
    
    return [[NSArray alloc] initWithArray:newArray];
}

- (NSArray *)arrayByMappingBlock:(id (^)(id theElement, NSUInteger theIndex))theBlock
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [newArray addObject:theBlock(obj, idx)];
    }];
    
    return [[NSArray alloc] initWithArray:newArray];
}
@end
