//
//  APIUpdateStreamMarker.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "APICall.h"

@interface APIUpdateStreamMarker : APICall
+ (void)updateStreamMarkerWithName:(NSString *)theStreamName postID:(NSString *)thePostID percentage:(CGFloat)thePercentage;
@end
