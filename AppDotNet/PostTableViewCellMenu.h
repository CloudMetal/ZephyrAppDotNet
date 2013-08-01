//
//  PostTableViewCellMenu.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

#define kPostTableViewCellMenuHeight 50

@class PostTableViewCellMenu;

@protocol PostTableViewCellMenuDelegate <NSObject>
- (void)postTableViewCellMenuChoseReply:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseRepost:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseNativeRepost:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseDelete:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseCopy:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseCopyURLOfPost:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseReplyAll:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseViewThread:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseViewProfile:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseMailPost:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseStar:(PostTableViewCellMenu *)thePostTableViewCellMenu;
- (void)postTableViewCellMenuChoseUnstar:(PostTableViewCellMenu *)thePostTableViewCellMenu;
@end

@interface PostTableViewCellMenu : UIView
@property (nonatomic, weak) IBOutlet id<PostTableViewCellMenuDelegate> delegate;

@property (nonatomic) BOOL isMenuForUserPost;
@property (nonatomic) BOOL isMenuForThreadPost;
@property (nonatomic) BOOL isMenuForStarredPost;
@property (nonatomic) BOOL shouldReplyAllBeAvailable;

- (void)makeAnEntrance;
@end
