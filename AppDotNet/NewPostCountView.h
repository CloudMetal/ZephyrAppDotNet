//
//  NewPostCountView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@class NewPostCountView;

@protocol NewPostCountViewDelegate <NSObject>
- (void)newPostCountViewRequestedScrollToUnread:(NewPostCountView *)theNewPostCountView;
@end

@interface NewPostCountView : UIView
@property (nonatomic, weak) id<NewPostCountViewDelegate> delegate;

@property (nonatomic) NSUInteger countOfNewPosts;
@property (nonatomic) BOOL shouldShowScrollToUnreadButton;
@end
