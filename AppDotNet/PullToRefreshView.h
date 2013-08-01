//
//  PullToRefreshView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

typedef enum {
    PullToRefreshStatePromptToPull,
    PullToRefreshStatePromptToRelease,
    PullToRefreshStateLoading
} PullToRefreshState;

@interface PullToRefreshView : UIView
@property (nonatomic) PullToRefreshState state;
@property (nonatomic) CGFloat pullProgress;
@end
