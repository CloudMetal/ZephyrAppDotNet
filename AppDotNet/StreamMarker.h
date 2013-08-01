//
//  StreamMarker.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface StreamMarker : NSObject
@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) CGFloat percentage;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSString *version;

+ (StreamMarker *)streamMarkerFromJSONRepresentation:(NSDictionary *)representation;
@end
