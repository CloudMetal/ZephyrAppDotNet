//
//  PostTableViewCell.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "AttributedStringLayout.h"
#import "LinkZone.h"
#import "PostTableViewCellMenu.h"

CGFloat PostTableViewCellGetAvatarSize();
CGFloat PostTableViewCellGetLeftContentInset();
CGFloat PostTableViewCellGetTopContentInset();
CGFloat PostTableViewCellGetRightContentInset();
CGFloat PostTableViewCellGetBottomContentInset();
CGFloat PostTableViewCellGetAnnotatedBottomContentInset();
CGFloat PostTableViewCellGetMinimumHeight();

extern NSString *PostTableViewCellSwipedRightNotification;

@class PostTableViewCell;

@protocol PostTableViewCellDelegate <NSObject>
- (void)tableViewCellSwiped:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellTapped:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCell:(PostTableViewCell *)theTableViewCell tappedLinkZone:(LinkZone *)theLinkZone;
- (BOOL)tableViewCell:(PostTableViewCell *)theTableViewCell longPressedLinkZone:(LinkZone *)theLinkZone;

- (void)tableViewCellPickedReply:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedRepost:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedNativeRepost:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedDelete:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedCopy:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedCopyURLOfPost:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedReplyAll:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedViewProfile:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedMailPost:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedStar:(PostTableViewCell *)theTableViewCell;
- (void)tableViewCellPickedUnstar:(PostTableViewCell *)theTableViewCell;
@end

@interface PostTableViewCell : UITableViewCell
@property (nonatomic, weak) id<PostTableViewCellDelegate> delegate;

@property (nonatomic) BOOL expanded;

@property (nonatomic) BOOL isAuthenticatedUser;
@property (nonatomic) BOOL mentionsAuthenticatedUser;
@property (nonatomic) BOOL isThread;
@property (nonatomic) BOOL hasMentions;
@property (nonatomic, copy) NSArray *linkZones;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, copy) NSURL *avatarURL;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *via;
@property (nonatomic, copy) NSString *repostedByUserName;
@property (nonatomic) BOOL youStarred;
@property (nonatomic, strong) AttributedStringLayout *layout;

- (void)makeAnEntrance;
@end
