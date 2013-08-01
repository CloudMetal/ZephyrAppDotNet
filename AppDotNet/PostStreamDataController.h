//
//  PostStreamDataController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "PostStreamData.h"
#import "API.h"
#import "PostStreamConfiguration.h"

@interface PostStreamDataController : NSObject
@property (nonatomic, strong) PostStreamConfiguration *configuration;
@property (nonatomic, copy) void (^apiCallMaker)(APIPostParameters *parameters, APIPostListCallback callback);
@property (nonatomic) NSUInteger numberOfPostsToInitiallyLoad;

@property (nonatomic) BOOL isViewVisible;
@property (nonatomic, readonly) BOOL loading;

@property (nonatomic, strong, readonly) PostStreamData *data;

- (void)shutdown;

- (void)refreshStream;
- (void)reloadAndRefreshStream;
- (void)loadMore;
- (void)loadMissingCellsFromBreakAtIndex:(NSUInteger)theBreakIndex;
@end
