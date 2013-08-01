//
//  PostSource.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface PostSource : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *link;

+ (PostSource *)postSourceFromJSONRepresentation:(NSDictionary *)representation;
@end
