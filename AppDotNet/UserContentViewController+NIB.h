//
//  UserContentViewController+NIB.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "UserContentViewController.h"
#import "AvatarImageView.h"

@interface UserContentViewController()
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic, strong) IBOutlet UILabel *prettyNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;

@property (nonatomic, strong) IBOutlet UILabel *bioLabel;
@property (nonatomic, strong) IBOutlet UILabel *joinDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *memberNumberLabel;

@property (nonatomic, strong) IBOutlet UIButton *followersButton;
@property (nonatomic, strong) IBOutlet UIButton *followingButton;
@property (nonatomic, strong) IBOutlet UIButton *postsButton;

@property (nonatomic, strong) IBOutlet UIButton *mentionsButton;
@property (nonatomic, strong) IBOutlet UIButton *starsButton;
@property (nonatomic, strong) IBOutlet UIButton *toggleFollowButton;
@property (nonatomic, strong) IBOutlet UIButton *toggleMuteButton;

@property (nonatomic, strong) IBOutlet UIImageView *profileBackgroundView;
@property (nonatomic, strong) IBOutlet AvatarImageView *avatarImageView;
@end
