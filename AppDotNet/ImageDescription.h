//
//  ImageDescription.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface ImageDescription : NSObject
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic, copy) NSURL *url;

+ (ImageDescription *)imageDescriptionFromJSONRepresentation:(NSDictionary *)representation;
@end
