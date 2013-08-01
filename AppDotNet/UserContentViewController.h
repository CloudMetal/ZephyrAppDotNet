//
//  UserContentViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "User.h"

@class UserContentViewController;

@protocol UserContentViewControllerDelegate <NSObject>
- (void)userContentViewControllerRequestsViewFollowers:(UserContentViewController *)theUserContentViewController;
- (void)userContentViewControllerRequestsViewFollowing:(UserContentViewController *)theUserContentViewController;
- (void)userContentViewControllerRequestsViewPosts:(UserContentViewController *)theUserContentViewController;
- (void)userContentViewControllerRequestsViewMentions:(UserContentViewController *)theUserContentViewController;
- (void)userContentViewControllerRequestsViewStars:(UserContentViewController *)theUserContentViewController;

- (void)userContentViewControllerRequestsViewAvatar:(UserContentViewController *)theUserContentViewController;

- (void)userContentViewControllerRequestsToggleFollow:(UserContentViewController *)theUserContentViewController;
- (void)userContentViewControllerRequestsToggleMute:(UserContentViewController *)theUserContentViewController;
@end

@interface UserContentViewController : UIViewController
@property (nonatomic, readonly) CGSize avatarSize;
@property (nonatomic, readonly) CGSize profileBackgroundSize;

@property (nonatomic, weak) IBOutlet id<UserContentViewControllerDelegate> delegate;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) UIImage *profileBackgroundImage;

- (void)repopulate;
@end
