//
//  PostStreamViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <MessageUI/MessageUI.h>
#import "PostStreamViewController.h"
#import "PostStreamDataController.h"
#import "PostTableViewCell.h"
#import "LoadMoreTableViewCell.h"
#import "ComposeViewController.h"
#import "UserViewController.h"
#import "WebBrowserViewController.h"
#import "ImageViewController.h"
#import "PadContentView.h"

#import "UserMentionStreamConfiguration.h"
#import "HashtagPostStreamConfiguration.h"
#import "ReplyPostStreamConfiguration.h"
#import "AttributedStringLayout.h"
#import "PullToRefreshView.h"
#import "LoadMoreView.h"
#import "LinkZone.h"
#import "AuthenticatedUser.h"
#import "UserSettings.h"
#import "URLMenu.h"
#import "NewPostCountView.h"
#import "ActivityNotificationView.h"

#define kShowThreadButtonTitle @"Show Thread"
#define kReplyButtonTitle @"Reply"
#define kRepostButtonTitle @"Repost"
#define kDeleteButtonTitle @"Delete"
#define kCopyButtonTitle @"Copy Post"
#define kViewProfileButtonTitle @"View Profile"
#define kCancelButtonTitle @"Cancel"

#define kReplyToAllInThreadTitle @"Reply to All"
#define kMailThreadTitle @"Mail Thread"

@interface PostStreamViewController() <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, PostTableViewCellDelegate, LoadMoreTableViewCellDelegate, MFMailComposeViewControllerDelegate, NewPostCountViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet PadContentView *contentView;

@property (nonatomic, strong) PullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) LoadMoreView *loadMoreView;
@property (nonatomic, strong) NewPostCountView *postCountView;
@property (nonatomic, strong) UIView *tableShadowView;

@property (nonatomic, strong) PostStreamDataController *postStreamDataController;
@property (nonatomic) NSUInteger relayoutCount;
@property (nonatomic, copy) NSArray *posts;
@property (nonatomic, copy) NSArray *layouts;
@property (nonatomic, copy) NSArray *cellHeights;
@property (nonatomic, copy) NSArray *cellLinkZones;

@property (nonatomic) BOOL shouldIgnoreActionTriggers;
@property (nonatomic, strong) Post *tappedPost;
@property (nonatomic, strong) Post *pendingDeletePost;

@property (nonatomic) BOOL nextRelayoutShouldScrollToSyncMarker;
@property (nonatomic) BOOL scrolledSinceLastSave;
@property (nonatomic, strong) NSTimer *autosaveStreamMarkerTimer;

- (void)finishInit;

- (void)registerObservers;
- (void)unregisterObservers;

- (void)relayout;
- (void)reloadNewPostIndicator;
- (void)reloadShouldScrollToUnreadButton;

- (void)saveStreamMarker;

- (void)collapseTappedCell;
- (void)replyToTappedPost;
- (void)repostTappedPost;
- (void)nativeRepostTappedPost;
- (void)deleteTappedPost;
- (void)copyTappedPost;
- (void)copyURLOfTappedPost;
- (void)replyToAllInTappedPost;
- (void)viewProfile;
- (void)mailPost;
- (void)starTappedPost;
- (void)unstarTappedPost;
@end

@implementation PostStreamViewController
- (id)init
{
    self = [super initWithNibName:@"PostStreamViewController" bundle:nil];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (void)finishInit
{
    [self registerObservers];
}

- (void)viewDidLoad
{
    self.contentView.backgroundStyle = PadContentViewBackgroundStyleDark;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.nextRelayoutShouldScrollToSyncMarker = YES;
    
    self.tableShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];
    self.tableShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"post-shadow.png"]];
    shadowImageView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 20);
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //[self.tableShadowView addSubview:shadowImageView];
    
    self.tableView.tableFooterView = self.tableShadowView;
    
    self.pullToRefreshView = [[PullToRefreshView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];
    self.tableView.tableHeaderView = self.pullToRefreshView;
    
    self.postCountView = [[NewPostCountView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32)];
    self.postCountView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.postCountView.delegate = self;
    [self.view addSubview:self.postCountView];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(!self.postStreamDataController) {
        self.postStreamDataController = [[PostStreamDataController alloc] init];
        self.postStreamDataController.configuration = self.postStreamConfiguration;
        self.postStreamDataController.apiCallMaker = self.postStreamConfiguration.apiCallMaker;
        
        if(self.postStreamConfiguration.idiom == PostStreamIdiomThread) {
            self.postStreamDataController.numberOfPostsToInitiallyLoad = 200;
        }
    }
    
    self.postStreamDataController.isViewVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.postStreamDataController.isViewVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(!self.navigationController) {
        [self.postStreamDataController shutdown];
    }
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)viewWillLayoutSubviews
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat tableViewWidth = 704;
        CGFloat tableViewLeft = roundf((self.view.bounds.size.width - tableViewWidth) * 0.5);
        self.tableView.frame = CGRectMake(tableViewLeft, 0, tableViewWidth, self.view.bounds.size.height);
        self.postCountView.frame = CGRectMake(tableViewLeft, self.postCountView.frame.origin.y, tableViewWidth, self.postCountView.frame.size.height);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"showUserName"]) {
        [self.tableView reloadData];
    } else if([keyPath isEqualToString:@"bodyFontSize"]) {
        [self relayout];
    } else if([keyPath isEqualToString:@"postStreamDataController.data.maxPostID"]) {
        [self reloadNewPostIndicator];
    } else if([keyPath isEqualToString:@"postStreamDataController.data.lastReadPostID"]) {
        [self reloadNewPostIndicator];
    } else if([keyPath isEqualToString:@"postStreamConfiguration"]) {
        self.postStreamDataController.configuration = self.postStreamConfiguration;
    } else if([keyPath isEqualToString:@"showDirectedPostsInUserStream"]) {
        [self.postStreamDataController reloadAndRefreshStream];
    }
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"showUserName" options:0 context:0];
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"bodyFontSize" options:0 context:0];
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"showDirectedPostsInUserStream" options:0 context:0];
    
    [self addObserver:self forKeyPath:@"postStreamDataController.data.maxPostID" options:0 context:0];
    [self addObserver:self forKeyPath:@"postStreamDataController.data.lastReadPostID" options:0 context:0];
    [self addObserver:self forKeyPath:@"postStreamConfiguration" options:0 context:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamDataDidUpdateNotification:) name:PostStreamDataDidUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIPostCreateDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIPostDeleteDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIPostRepostDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIUserFollowDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIUserUnfollowDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIUserMuteDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIUserUnmuteDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIPostStarDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamUpdateNotificationDidOccur:) name:APIPostUnstarDidFinishNotification object:nil];
}

- (void)unregisterObservers
{
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"showUserName"];
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"bodyFontSize"];
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"showDirectedPostsInUserStream"];
    
    [self removeObserver:self forKeyPath:@"postStreamDataController.data.maxPostID"];
    [self removeObserver:self forKeyPath:@"postStreamDataController.data.lastReadPostID"];
    [self removeObserver:self forKeyPath:@"postStreamConfiguration"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PostStreamDataDidUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIPostCreateDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIPostDeleteDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIPostRepostDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIUserFollowDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIUserUnfollowDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIUserMuteDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIUserUnmuteDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIPostStarDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIPostUnstarDidFinishNotification object:nil];
}

- (NSArray *)transformLinkRects:(NSArray *)untransformed cellHeight:(CGFloat)cellHeight bottom:(CGFloat)bottom
{
    NSMutableArray *newRects = [[NSMutableArray alloc] init];
    
    for(NSValue *rectValue in untransformed) {
        CGRect rect = rectValue.CGRectValue;
        
        rect.origin.x += PostTableViewCellGetLeftContentInset();
        rect.origin.y = cellHeight - (bottom + rect.origin.y + rect.size.height);
        
        [newRects addObject:[NSValue valueWithCGRect:rect]];
    }
    
    return newRects;
}

- (void)relayout
{
    self.shouldIgnoreActionTriggers = YES;
    self.relayoutCount++;
    BOOL layingOutFirstLoad = self.posts.count == 0;
    NSUInteger newRelayoutCount = self.relayoutCount;
    NSMutableArray *newLayouts = [[NSMutableArray alloc] init];
    NSMutableArray *newCellHeights = [[NSMutableArray alloc] init];
    NSMutableArray *newCellLinkZones = [[NSMutableArray alloc] init];
    NSMutableArray *newPosts = [[NSMutableArray alloc] init];
    BOOL newHasMorePostsAtEndOfStream = self.postStreamDataController.data.hasMorePostsAtEndOfStream;
    for(NSUInteger i=0; i<self.postStreamDataController.data.countOfElements; i++) {
        if([self.postStreamDataController.data elementTypeAtIndex:i] == PostStreamElementTypePost) {
            [newPosts addObject:[self.postStreamDataController.data postAtIndex:i]];
        } else {
            [newPosts addObject:[NSNull null]];
        }
    }
    
    /*if(self.postStreamConfiguration.idiom == PostStreamIdiomThread) {
        NSMutableArray *invertedPosts = [[NSMutableArray alloc] init];
        
        for(Post *post in newPosts) {
            [invertedPosts insertObject:post atIndex:0];
        }
        
        newPosts = invertedPosts;
    }*/
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(__strong Post *post in newPosts) {
            if([post isKindOfClass:[NSNull class]]) {
                [newCellLinkZones addObject:[NSNull null]];
                [newCellHeights addObject:[NSNumber numberWithFloat:44]];
                [newLayouts addObject:[NSNull null]];
                
                continue;
            }
            
            BOOL isRepost = post.repostOf != nil;
            if(post.repostOf) {
                post = post.repostOf;
            }
            
            isRepost |= post.youReposted;
            
            AttributedStringLayout *layout = [[AttributedStringLayout alloc] init];
            NSMutableAttributedString *attributedString = nil;
            
            if(post.text) {
                attributedString = [[NSMutableAttributedString alloc] initWithString:post.text];
            } else if(post.isDeleted) {
                attributedString = [[NSMutableAttributedString alloc] initWithString:@"Post Deleted"];
            } else {
                NSLog(@"WTF? Got no text, but the post isn't deleted in post %@", post.postID);
            }
            
            // Mark attributes
            CGFloat fontSize = [[UserSettings sharedUserSettings] bodyFontSize];
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                fontSize *= kPadFontScale;
            }
            
            [attributedString addFontAttribute:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0, attributedString.length)];
            [attributedString addColorAttribute:[UIColor postBodyTextColor] range:NSMakeRange(0, attributedString.length)];
            for(MentionEntity *mention in post.entities.mentions) {
                [attributedString addFontAttribute:[UIFont boldSystemFontOfSize:fontSize] range:mention.range];
                [attributedString addColorAttribute:[UIColor postLinkTextColor] range:mention.range];
            }
            for(LinkEntity *link in post.entities.links) {
                [attributedString addFontAttribute:[UIFont boldSystemFontOfSize:fontSize] range:link.range];
                [attributedString addColorAttribute:[UIColor postLinkTextColor] range:link.range];
            }
            for(HashtagEntity *hashtag in post.entities.hashtags) {
                [attributedString addFontAttribute:[UIFont boldSystemFontOfSize:fontSize] range:hashtag.range];
                [attributedString addColorAttribute:[UIColor postLinkTextColor] range:hashtag.range];
            }
            
            if(post.isDeleted) {
                [attributedString addFontAttribute:[UIFont italicSystemFontOfSize:fontSize] range:NSMakeRange(0, attributedString.length)];
            }
            
            layout.attributedString = attributedString;
            
            // Find the bounds of the content
            CGFloat contentWidth = self.tableView.bounds.size.width - (PostTableViewCellGetLeftContentInset() + PostTableViewCellGetRightContentInset());
            
            CGFloat bottomInset = (isRepost ? PostTableViewCellGetAnnotatedBottomContentInset() : PostTableViewCellGetBottomContentInset());
            CGFloat minimumCellHeight = (post.youStarred ? PostTableViewCellGetMinimumHeight() + 20 : PostTableViewCellGetMinimumHeight());
            
            CGSize suggestedSize = [layout textSizeWithinSize:CGSizeMake(contentWidth, CGFLOAT_MAX)];
            CGFloat calculatedCellHeight = suggestedSize.height + PostTableViewCellGetTopContentInset() + bottomInset;
            CGFloat paddingDelta = 0;
            if(minimumCellHeight > calculatedCellHeight) {
                paddingDelta = minimumCellHeight - calculatedCellHeight;
                calculatedCellHeight = minimumCellHeight;
            }
            
            // Create layout path
            // We set the y-coordinate to the bottom cell content inset because
            // we're going to flip the context upside-down when we render.
            CGPathRef path = CGPathCreateWithRect(CGRectMake(PostTableViewCellGetLeftContentInset(), bottomInset + paddingDelta, contentWidth, suggestedSize.height), NULL);
            layout.path = path;
            CFRelease(path);
            
            // Create link zones
            NSMutableArray *linkZones = [[NSMutableArray alloc] init];
            for(MentionEntity *mention in post.entities.mentions) {
                NSArray *untransformed = [layout CGRectValuesEnclosingStringRange:CFRangeMake(mention.range.location, mention.range.length)];
                LinkZone *linkZone = [[LinkZone alloc] init];
                linkZone.rects = [self transformLinkRects:untransformed cellHeight:calculatedCellHeight bottom:bottomInset + paddingDelta];
                linkZone.type = LinkZoneTypeUser;
                linkZone.link = mention.userID;
                [linkZones addObject:linkZone];
            }
            for(LinkEntity *link in post.entities.links) {
                NSArray *untransformed = [layout CGRectValuesEnclosingStringRange:CFRangeMake(link.range.location, link.range.length)];
                LinkZone *linkZone = [[LinkZone alloc] init];
                linkZone.rects = [self transformLinkRects:untransformed cellHeight:calculatedCellHeight bottom:bottomInset + paddingDelta];
                linkZone.type = LinkZoneTypeLink;
                linkZone.link = link.url.absoluteString;
                [linkZones addObject:linkZone];
            }
            for(HashtagEntity *hashtag in post.entities.hashtags) {
                NSArray *untransformed = [layout CGRectValuesEnclosingStringRange:CFRangeMake(hashtag.range.location, hashtag.range.length)];
                LinkZone *linkZone = [[LinkZone alloc] init];
                linkZone.rects = [self transformLinkRects:untransformed cellHeight:calculatedCellHeight bottom:bottomInset + paddingDelta];
                linkZone.type = LinkZoneTypeHashtag;
                linkZone.link = hashtag.name;
                [linkZones addObject:linkZone];
            }
            
            // Avatar link zone
            LinkZone *linkZone = [[LinkZone alloc] init];
            CGFloat avatarTop = PostTableViewCellGetTopContentInset() - 20;
            CGFloat avatarLeft = PostTableViewCellGetLeftContentInset() - PostTableViewCellGetAvatarSize() - 10;
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                avatarTop -= 5;
                avatarLeft -= 5;
            }
            
            linkZone.rects = [NSArray arrayWithObject:[NSValue valueWithCGRect:CGRectMake(avatarLeft, avatarTop, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize())]];
            linkZone.type = LinkZoneTypeUser;
            linkZone.link = post.user.userID;
            [linkZones addObject:linkZone];
            
            [newCellLinkZones addObject:linkZones];
            
            // Add to arrays
            [newLayouts addObject:layout];
            [newCellHeights addObject:[NSNumber numberWithFloat:calculatedCellHeight]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *topPostID = nil;
            CGFloat offsetFromTopPost = 0;
            
            NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
            for(int i=0; i<visibleIndexPaths.count; i++) {
                NSIndexPath *indexPath = [visibleIndexPaths objectAtIndex:i];
                
                if([[self.posts objectAtIndex:indexPath.row] isKindOfClass:[Post class]]) {
                    topPostID = [[self.posts objectAtIndex:indexPath.row] postID];
                    UITableViewCell *topCell = [self.tableView cellForRowAtIndexPath:indexPath];
                    offsetFromTopPost = topCell.frame.origin.y - self.tableView.contentOffset.y;
                    break;
                }
            }
            
            if(newRelayoutCount >= self.relayoutCount) {
                self.layouts = newLayouts;
                self.cellHeights = newCellHeights;
                self.posts = newPosts;
                self.cellLinkZones = newCellLinkZones;
                [self.tableView reloadData];
                if(newHasMorePostsAtEndOfStream) {
                    if(!self.loadMoreView) {
                        self.loadMoreView = [[LoadMoreView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
                        self.loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    }
                    
                    self.tableView.tableFooterView = self.loadMoreView;
                } else {
                    self.tableView.tableFooterView = self.tableShadowView;
                }
                
                if(topPostID) {
                    CGFloat top = 0;
                    for(NSUInteger i=0; i<self.posts.count; i++) {
                        Post *post = [self.posts objectAtIndex:i];
                        if([post isKindOfClass:[NSNull class]]) {
                            top += [[self.cellHeights objectAtIndex:i] floatValue];
                            continue;
                        }
                        
                        if([post.postID isEqualToString:topPostID]) {
                            if(offsetFromTopPost == 0 && top > 0) {
                                [self.tableView setContentOffset:CGPointMake(0, top)];
                                [self.tableView setContentOffset:CGPointMake(0, top - 30) animated:YES];
                            } else {
                                self.tableView.contentOffset = CGPointMake(0, top - offsetFromTopPost);
                            }
                            break;
                        }
                        
                        top += [[self.cellHeights objectAtIndex:i] floatValue];
                    }
                }
                
                if(self.focusedPostID && self.posts.count > 0) {
                    CGFloat top = 0;
                    for(NSUInteger i=0; i<self.posts.count; i++) {
                        Post *post = [self.posts objectAtIndex:i];
                        if([post isKindOfClass:[NSNull class]]) {
                            top += [[self.cellHeights objectAtIndex:i] floatValue];
                            continue;
                        }
                        
                        if([post.postID isEqualToString:self.focusedPostID]) {
                            CGRect rect = CGRectMake(0, top - 150, self.view.bounds.size.width, [[self.cellHeights objectAtIndex:i] floatValue] + 300);
                            [self.tableView scrollRectToVisible:rect animated:NO];
                            [self.tableView flashScrollIndicators];
                            break;
                        }
                        
                        top += [[self.cellHeights objectAtIndex:i] floatValue];
                    }
                    
                    self.focusedPostID = nil;
                }
                
                self.pullToRefreshView.state = PullToRefreshStatePromptToPull;
                self.pullToRefreshView.pullProgress = 0;
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.tableView.contentInset = UIEdgeInsetsZero;
                } completion:^(BOOL finished) {
                    
                }];
                
                if(self.postStreamConfiguration.idiom == PostStreamIdiomThread) {
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(threadActions:)];
                }
                
                if(self.postStreamDataController.data.streamMarker.postID) {
                    if([self.postStreamDataController.data.streamMarker.postID longLongValue] > [self.postStreamDataController.data.lastReadPostID longLongValue]) {
                        if(self.nextRelayoutShouldScrollToSyncMarker) {
                            self.nextRelayoutShouldScrollToSyncMarker = NO;
                            
                            CGFloat top = 0;
                            for(NSUInteger i=0; i<self.posts.count; i++) {
                                Post *post = [self.posts objectAtIndex:i];
                                if([post isKindOfClass:[NSNull class]]) {
                                    top += [[self.cellHeights objectAtIndex:i] floatValue];
                                    continue;
                                }
                                
                                if([post.postID isEqualToString:self.postStreamDataController.data.streamMarker.postID]) {
                                    top -= self.postCountView.bounds.size.height;
                                    top = MAX(top, 0);
                                    top = MIN(top, self.tableView.contentSize.height - self.tableView.bounds.size.height);
                                    
                                    if(self.tableView.contentSize.height > self.tableView.bounds.size.height) {
                                        [self.tableView setContentOffset:CGPointMake(0, top) animated:YES];
                                    }
                                    [self.tableView flashScrollIndicators];
                                    break;
                                }
                                
                                top += [[self.cellHeights objectAtIndex:i] floatValue];
                            }
                        }
                        self.postStreamDataController.data.lastReadPostID = self.postStreamDataController.data.streamMarker.postID;
                    }
                }
                
                if((self.posts > 0) && (layingOutFirstLoad == YES) && (self.postStreamDataController.data.streamMarker.postID != nil)) {
                    CGFloat top = 0;
                    BOOL scrolled = NO;
                    for(NSUInteger i=0; i<self.posts.count; i++) {
                        Post *post = [self.posts objectAtIndex:i];
                        if([post isKindOfClass:[NSNull class]]) {
                            top += [[self.cellHeights objectAtIndex:i] floatValue];
                            continue;
                        }
                        
                        if([post.postID isEqualToString:self.postStreamDataController.data.streamMarker.postID]) {
                            top -= self.postCountView.bounds.size.height;
                            top = MAX(top, 0);
                            top = MIN(top, self.tableView.contentSize.height - self.tableView.bounds.size.height);
                            
                            if(self.tableView.contentSize.height > self.tableView.bounds.size.height) {
                                [self.tableView setContentOffset:CGPointMake(0, top) animated:NO];
                            }
                            [self.tableView flashScrollIndicators];
                            scrolled = YES;
                            break;
                        }
                        
                        top += [[self.cellHeights objectAtIndex:i] floatValue];
                    }
                    
                    if(scrolled) {
                        self.postStreamDataController.data.lastReadPostID = self.postStreamDataController.data.streamMarker.postID;
                    }
                }
                
                [self reloadNewPostIndicator];
                
                self.shouldIgnoreActionTriggers = NO;
            }
        });
    });
}

- (void)reloadNewPostIndicator
{
    NSUInteger countOfNewPosts = 0;
    
    if(self.postStreamDataController.data.maxPostID != nil && self.postStreamDataController.data.lastReadPostID != nil) {
        for(Post *post in self.posts) {
            if(post == (Post *)[NSNull null]) {
                continue;
            }
            
            if(![post.postID isEqual:self.postStreamDataController.data.lastReadPostID]) {
                countOfNewPosts++;
            } else {
                break;
            }
            
            // If we found the last post, zero out the count of new posts to avoid bugs.
            if(post == self.posts.lastObject) {
                countOfNewPosts = 0;
            }
        }
    }
    
    //if(self.postStreamConfiguration.idiom != PostStreamIdiomThread) {
        NSUInteger oldCount = self.postCountView.countOfNewPosts;
        self.postCountView.countOfNewPosts = countOfNewPosts;
        
        if(oldCount == 0 && countOfNewPosts > 0) {
            [self reloadShouldScrollToUnreadButton];
        }
    //}
    
    if(self.postStreamDataController.data.maxPostID != nil && self.postStreamDataController.data.lastReadPostID != nil && ![self.postStreamDataController.data.maxPostID isEqual:self.postStreamDataController.data.lastReadPostID]) {
        if([self.navigationController.viewControllers objectAtIndex:0] == self) {
            self.navigationController.adnTabBarItem.hasNewPosts = YES;
            if(countOfNewPosts == 0) {
                self.navigationController.adnTabBarItem.hasNewPosts = NO;
            }
        }
    } else {
        if([self.navigationController.viewControllers objectAtIndex:0] == self) {
            self.navigationController.adnTabBarItem.hasNewPosts = NO;
        }
    }
}

- (void)reloadShouldScrollToUnreadButton
{
    if(self.postCountView.countOfNewPosts > 0) {
        NSString *lastReadPostID = self.postStreamDataController.data.lastReadPostID;
        self.postCountView.shouldShowScrollToUnreadButton = YES;
        if(lastReadPostID) {
            NSArray *indexPathsForVisibleRows = [self.tableView indexPathsForVisibleRows];
            for(NSIndexPath *indexPath in indexPathsForVisibleRows) {
                NSUInteger row = indexPath.row;
                
                if([self.postStreamDataController.data elementTypeAtIndex:row] == PostStreamElementTypePost) {
                    Post *post = [self.postStreamDataController.data postAtIndex:row];
                    if(post.postID.longLongValue > lastReadPostID.longLongValue) {
                        self.postCountView.shouldShowScrollToUnreadButton = NO;
                    }
                }
            }
        }
    }
}

- (void)saveStreamMarker
{
    if(self.scrolledSinceLastSave == NO) {
        return;
    }
    
    if(self.postStreamConfiguration.updatesStreamMarker == NO) {
        return;
    }
    
    if(self.postStreamDataController.data.streamMarker.name == nil) {
        return;
    }
    
    self.scrolledSinceLastSave = NO;
    
    [APIUpdateStreamMarker updateStreamMarkerWithName:self.postStreamDataController.data.streamMarker.name postID:self.postStreamDataController.data.lastReadPostID percentage:0];
}

- (void)collapseTappedCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        PostTableViewCell *cell = (PostTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.posts indexOfObject:self.tappedPost] inSection:0]];
        cell.expanded = NO;
        self.tappedPost = nil;
        [self.tableView endUpdates];
    });
}

- (void)replyToTappedPost
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.replyID = self.tappedPost.postID;
    composeViewController.replyUserName = self.tappedPost.user.userName;
    composeViewController.replyText = self.tappedPost.text;
    composeViewController.defaultText = [NSString stringWithFormat:@"@%@ ", self.tappedPost.user.userName];
    [composeViewController presentInViewController:self];
}

- (void)repostTappedPost
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.replyID = self.tappedPost.postID;
    composeViewController.replyUserName = self.tappedPost.user.userName;
    composeViewController.defaultText = [NSString stringWithFormat:@">> @%@: %@", self.tappedPost.user.userName, self.tappedPost.text];
    composeViewController.shouldStartEditingFromBeginning = YES;
    [composeViewController presentInViewController:self];
}

- (void)nativeRepostTappedPost
{
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    [APIPostRepost repostPostWithID:self.tappedPost.postID completionHandler:^(Post *post, NSError *error) {
        notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
        [notificationView dismissAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APIPostRepostDidFinishNotification object:nil];
    }];
}

- (void)deleteTappedPost
{
    self.pendingDeletePost = self.tappedPost;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Post" message:@"Do you really want to delete this post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kDeleteButtonTitle, nil];
    [alertView show];
}

- (void)copyTappedPost
{
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    notificationView.state = ActivityNotificationViewStateAccepted;
    [notificationView dismissAnimated:YES];
    
    [[UIPasteboard generalPasteboard] setString:self.tappedPost.text];
}

- (void)copyURLOfTappedPost
{
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    notificationView.state = ActivityNotificationViewStateAccepted;
    [notificationView dismissAnimated:YES];
    
    [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://alpha.app.net/%@/post/%@", self.tappedPost.user.userName, self.tappedPost.postID]]];
}

- (void)replyToAllInTappedPost
{
    NSMutableArray *mentionsArray = [[NSMutableArray alloc] init];
    NSMutableString *mentionsString = [[NSMutableString alloc] initWithString:@""];
    [mentionsArray addObject:self.tappedPost.user.userName];
    for(MentionEntity *mention in self.tappedPost.entities.mentions) {
        if(![mentionsArray containsObject:mention.name]) {
            [mentionsArray addObject:mention.name];
        }
    }
    
    [mentionsArray removeObject:[[[AuthenticatedUser sharedAuthenticatedUser] user] userName]];
    
    for(NSString *name in mentionsArray) {
        [mentionsString appendFormat:@"@%@ ", name];
    }
    
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.replyID = self.tappedPost.postID;
    composeViewController.replyUserName = self.tappedPost.user.userName;
    composeViewController.replyText = self.tappedPost.text;
    composeViewController.defaultText = mentionsString;
    [composeViewController presentInViewController:self];
}

- (void)viewProfile
{
    UserViewController *controller = [[UserViewController alloc] init];
    controller.userID = self.tappedPost.user.userID;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)mailPost
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    [controller setSubject:[NSString stringWithFormat:@"Post by %@ on App.net", self.tappedPost.user.name]];
    [controller setMessageBody:self.tappedPost.html isHTML:YES];
    [self presentModalViewController:controller animated:YES];
}

- (void)starTappedPost
{
    NSString *postID = self.tappedPost.postID;
    if(self.tappedPost.repostOf) {
        postID = self.tappedPost.repostOf.postID;
    }
    
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    
    [APIPostStar starPostWithID:postID completionHandler:^(Post *post, NSError *error) {
        notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
        [notificationView dismissAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APIPostStarDidFinishNotification object:nil];
    }];
}

- (void)unstarTappedPost
{
    NSString *postID = self.tappedPost.postID;
    if(self.tappedPost.repostOf) {
        postID = self.tappedPost.repostOf.postID;
    }
    
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    
    [APIPostUnstar unstarPostWithID:postID completionHandler:^(Post *post, NSError *error) {
        notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
        [notificationView dismissAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APIPostUnstarDidFinishNotification object:nil];
    }];
}

#pragma mark -
#pragma mark Actions
- (void)threadActions:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:kReplyToAllInThreadTitle];
    
    if([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:kMailThreadTitle];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    
    [actionSheet showInView:self.navigationController.view.superview];
}

- (void)autosaveStreamMarker:(NSTimer *)theTimer
{
    [self.autosaveStreamMarkerTimer invalidate];
    self.autosaveStreamMarkerTimer = nil;
    
    [self saveStreamMarker];
}

#pragma mark -
#pragma mark Notifications
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.nextRelayoutShouldScrollToSyncMarker = YES;
    [self saveStreamMarker];
}

- (void)streamDataDidUpdateNotification:(NSNotification *)notification
{
    if(notification.object == self.postStreamDataController.data) {
        [self relayout];
    } else {
        [self view];
        if(!self.postStreamDataController) {
            self.postStreamDataController = [[PostStreamDataController alloc] init];
            self.postStreamDataController.configuration = self.postStreamConfiguration;
            self.postStreamDataController.apiCallMaker = self.postStreamConfiguration.apiCallMaker;
            
            if(self.postStreamConfiguration.idiom == PostStreamIdiomThread) {
                self.postStreamDataController.numberOfPostsToInitiallyLoad = 200;
            }
        }
    }
}

- (void)streamUpdateNotificationDidOccur:(NSNotification *)notification
{
    [self.postStreamDataController reloadAndRefreshStream];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat menuHeight = 0;
    
    if([self.posts objectAtIndex:indexPath.row] == self.tappedPost) {
        menuHeight = kPostTableViewCellMenuHeight;
    }
    
    return [[self.cellHeights objectAtIndex:indexPath.row] floatValue] + menuHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.posts objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        LoadMoreTableViewCell *cell = [[LoadMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.delegate = self;
        return cell;
    }
    
    PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postTableViewCell"];
    if(!cell) {
        cell = [[PostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postTableViewCell"];
    }
    
    Post *post = [self.posts objectAtIndex:indexPath.row];
    NSString *reposterName = nil;
    
    if(post.repostOf) {
        if([[UserSettings sharedUserSettings] showUserName]) {
            reposterName = post.user.userName;
        } else {
            reposterName = post.user.name;
        }
        
        post = post.repostOf;
    }
    
    if(post.youReposted) {
        reposterName = @"you";
    }
    
    cell.delegate = self;
    cell.linkZones = [self.cellLinkZones objectAtIndex:indexPath.row];
    cell.layout = [self.layouts objectAtIndex:indexPath.row];
    if([[UserSettings sharedUserSettings] showUserName]) {
        cell.userName = post.user.userName;
    } else {
        cell.userName = post.user.name;
    }
    
    cell.repostedByUserName = reposterName;
    cell.via = post.postSource.name;
    cell.avatarURL = post.user.avatarImage.url;
    cell.creationDate = post.createdAt;
    cell.isAuthenticatedUser = [post.user.userID isEqual:[[[AuthenticatedUser sharedAuthenticatedUser] user] userID]];
    cell.isThread = (self.postStreamConfiguration.idiom == PostStreamIdiomThread);
    cell.expanded = post == self.tappedPost;
    cell.youStarred = post.youStarred;
    
    cell.mentionsAuthenticatedUser = NO;
    NSUInteger mentionsCount = post.entities.mentions.count;
    for(MentionEntity *mention in post.entities.mentions) {
        if([mention.userID isEqualToString:[[[AuthenticatedUser sharedAuthenticatedUser] user] userID]]) {
            mentionsCount--;
            cell.mentionsAuthenticatedUser = YES;
        }
    }
    cell.hasMentions = mentionsCount > 0;
    
    [cell setNeedsDisplay];
    
    return cell;
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.shouldIgnoreActionTriggers) {
        self.pullToRefreshView.state = PullToRefreshStateLoading;
        return;
    }
    
    self.scrolledSinceLastSave = YES;
    [self.autosaveStreamMarkerTimer invalidate];
    self.autosaveStreamMarkerTimer = nil;
    
    if(self.postStreamConfiguration.updatesStreamMarker) {
        self.autosaveStreamMarkerTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(autosaveStreamMarker:) userInfo:nil repeats:NO];
    }
    
    [self reloadShouldScrollToUnreadButton];
    
    if(self.tableView.visibleCells.count > 0) {
        NSArray *indexPathsForVisibleRows = [self.tableView indexPathsForVisibleRows];
        BOOL changedFocus = NO;
        for(NSIndexPath *indexPath in indexPathsForVisibleRows) {
            NSUInteger row = indexPath.row;
            
            if([self.postStreamDataController.data elementTypeAtIndex:row] == PostStreamElementTypePost) {
                Post *post = [self.postStreamDataController.data postAtIndex:row];
                if(changedFocus == NO) {
                    changedFocus = YES;
                    self.postStreamDataController.data.currentFocusPostID = post.postID;
                }
                if([self.postStreamDataController.data.lastReadPostID longLongValue] < post.postID.longLongValue) {
                    CGRect cellRect = [[self.tableView cellForRowAtIndexPath:indexPath] frame];
                    CGRect visibleRect = CGRectMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
                    if(CGRectIntersection(cellRect, visibleRect).origin.y <= cellRect.origin.y) {
                        self.postStreamDataController.data.lastReadPostID = post.postID;
                    }
                }
            }
        }
    }
    
    if(self.postStreamDataController.loading) {
        self.pullToRefreshView.state = PullToRefreshStateLoading;
    } else if(scrollView.contentOffset.y <= -50 && !scrollView.isDecelerating) {
        self.pullToRefreshView.state = PullToRefreshStatePromptToRelease;
        self.pullToRefreshView.pullProgress = 1.0f;
    } else {
        self.pullToRefreshView.state = PullToRefreshStatePromptToPull;
        CGFloat progress = MIN(MAX(0, -scrollView.contentOffset.y / 50), 1);
        self.pullToRefreshView.pullProgress = progress;
    }
    
    if(self.postStreamDataController.data.hasMorePostsAtEndOfStream) {
        if(scrollView.contentOffset.y + scrollView.bounds.size.height > (self.loadMoreView.frame.origin.y - 40)) {
            [self.postStreamDataController loadMore];
            self.pullToRefreshView.state = PullToRefreshStateLoading;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.shouldIgnoreActionTriggers) {
        return;
    }
    
    if(scrollView.contentOffset.y <= -50) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
        } completion:^(BOOL finished) {
            
        }];
        
        [self.postStreamDataController refreshStream];
        self.pullToRefreshView.state = PullToRefreshStateLoading;
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:kShowThreadButtonTitle]) {
        NSString *postID = self.tappedPost.postID;
        
        ReplyPostStreamConfiguration *configuration = [[ReplyPostStreamConfiguration alloc] init];
        configuration.postID = postID;
        
        PostStreamViewController *viewController = [[PostStreamViewController alloc] init];
        viewController.focusedPostID = self.tappedPost.postID;
        viewController.title = @"Thread";
        viewController.postStreamConfiguration = configuration;
        [self.navigationController pushViewController:viewController animated:YES];
    } else if([title isEqualToString:kReplyButtonTitle]) {
        [self replyToTappedPost];
    } else if([title isEqualToString:kRepostButtonTitle]) {
        [self repostTappedPost];
    } else if([title isEqualToString:kDeleteButtonTitle]) {
        [self deleteTappedPost];
    } else if([title isEqualToString:kCopyButtonTitle]) {
        [self copyTappedPost];
    } else if([title isEqualToString:kViewProfileButtonTitle]) {
        UserViewController *controller = [[UserViewController alloc] init];
        controller.userID = self.tappedPost.user.userID;
        [self.navigationController pushViewController:controller animated:YES];
    } else if([title isEqualToString:kReplyToAllInThreadTitle]) {
        NSMutableArray *mentionsArray = [[NSMutableArray alloc] init];
        NSMutableString *mentionsString = [[NSMutableString alloc] initWithString:@""];
        [self.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Post *post = obj;
            
            if(![mentionsArray containsObject:post.user.userName]) {
                [mentionsArray addObject:post.user.userName];
            }
            
            for(MentionEntity *mention in post.entities.mentions) {
                if(![mentionsArray containsObject:mention.name]) {
                    [mentionsArray addObject:mention.name];
                }
            }
        }];
        
        [mentionsArray removeObject:[[[AuthenticatedUser sharedAuthenticatedUser] user] userName]];
        
        for(NSString *name in mentionsArray) {
            [mentionsString appendFormat:@"@%@ ", name];
        }
        
        ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
        composeViewController.replyID = [[self.posts objectAtIndex:0] postID];
        composeViewController.replyUserName = self.tappedPost.user.userName;
        composeViewController.defaultText = mentionsString;
        [composeViewController presentInViewController:self];
    } else if([title isEqualToString:kMailThreadTitle]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        [controller setSubject:@"Thread on App.net"];
        
        NSMutableString *threadHTML = [[NSMutableString alloc] initWithString:@""];
        
        [self.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Post *post = obj;
            
            [threadHTML appendFormat:@"<b>%@</b><br>", post.user.name];
            [threadHTML appendString:post.html];
            
            if(idx != self.posts.count - 1) {
                [threadHTML appendString:@"<br><br>"];
            }
        }];
        
        [controller setMessageBody:threadHTML isHTML:YES];
        [self presentModalViewController:controller animated:YES];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kDeleteButtonTitle]) {
        ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
        [notificationView showInWindow:self.view.window animated:YES];
        
        [APIPostDelete deletePostWithID:self.pendingDeletePost.postID completionHandler:^(Post *post, NSError *error) {
            notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
            [notificationView dismissAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APIPostDeleteDidFinishNotification object:nil];
        }];
    }
    
    self.pendingDeletePost = nil;
}

#pragma mark -
#pragma mark PostTableViewCellDelegate
- (void)tableViewCellSwiped:(PostTableViewCell *)theTableViewCell
{
    if(self.postStreamConfiguration.idiom == PostStreamIdiomThread) {
        return;
    }
    
    [self collapseTappedCell];
    
    Post *swipedPost = [self.posts objectAtIndex:[self.tableView indexPathForCell:theTableViewCell].row];
    
    NSString *postID = swipedPost.postID;
    
    if(swipedPost.repostOf) {
        postID = swipedPost.repostOf.postID;
    }
    
    ReplyPostStreamConfiguration *configuration = [[ReplyPostStreamConfiguration alloc] init];
    configuration.postID = postID;
    
    PostStreamViewController *viewController = [[PostStreamViewController alloc] init];
    viewController.focusedPostID = postID;
    viewController.title = @"Thread";
    viewController.postStreamConfiguration = configuration;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tableViewCellTapped:(PostTableViewCell *)theTableViewCell
{
    [self.tableView beginUpdates];
    if(self.tappedPost) {
        if([self.posts indexOfObject:self.tappedPost] != NSNotFound) {
            PostTableViewCell *cell = (PostTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.posts indexOfObject:self.tappedPost] inSection:0]];
            cell.expanded = NO;
        }
    }
    
    if(self.tappedPost == [self.posts objectAtIndex:[self.tableView indexPathForCell:theTableViewCell].row]) {
        self.tappedPost = nil;
    } else {
        self.tappedPost = [self.posts objectAtIndex:[self.tableView indexPathForCell:theTableViewCell].row];
        
        PostTableViewCell *cell = (PostTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.posts indexOfObject:self.tappedPost] inSection:0]];
        cell.expanded = YES;
        [cell makeAnEntrance];
    }
    
    [self.tableView endUpdates];
    
    if(self.tappedPost) {
        PostTableViewCell *cell = (PostTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.posts indexOfObject:self.tappedPost] inSection:0]];
        CGRect rect = CGRectMake(0, cell.frame.origin.y + cell.frame.size.height - kPostTableViewCellMenuHeight, cell.frame.size.width, kPostTableViewCellMenuHeight);
        
        if(rect.origin.y + rect.size.height <= self.tableView.contentSize.height) {
            [self.tableView scrollRectToVisible:rect animated:YES];
        } else {
            [self.tableView setContentOffset:CGPointMake(0, MAX(0, (rect.origin.y + rect.size.height) - self.tableView.bounds.size.height)) animated:YES];
        }
    }
}

- (void)tableViewCell:(PostTableViewCell *)theTableViewCell tappedLinkZone:(LinkZone *)theLinkZone
{
    [self collapseTappedCell];
    
    NSError *error = nil;
    NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"alpha\\.app\\.net/hashtags/(.+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *postRegex = [NSRegularExpression regularExpressionWithPattern:@"alpha\\.app\\.net/[a-z0-9_]+/post/([0-9]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *shortPostRegex = [NSRegularExpression regularExpressionWithPattern:@"posts\\.app\\.net/([0-9]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *userRegex =[NSRegularExpression regularExpressionWithPattern:@"alpha\\.app\\.net/([a-z0-9_]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(error) {
        NSLog(@"REGEX PARSE ERROR: %@", error);
    }
    
    if(theLinkZone.type == LinkZoneTypeHashtag) {
        PostStreamViewController *controller = [[PostStreamViewController alloc] init];
        HashtagPostStreamConfiguration *configuration = [[HashtagPostStreamConfiguration alloc] init];
        configuration.hashtag = theLinkZone.link;
        controller.postStreamConfiguration = configuration;
        controller.title = [NSString stringWithFormat:@"#%@", configuration.hashtag];
        [self.navigationController pushViewController:controller animated:YES];
    } else if(theLinkZone.type == LinkZoneTypeUser) {
        UserViewController *controller = [[UserViewController alloc] init];
        controller.userID = theLinkZone.link;
        [self.navigationController pushViewController:controller animated:YES];
    } else if(theLinkZone.type == LinkZoneTypeLink) {
        if([ImageViewController canHandleURL:[NSURL URLWithString:theLinkZone.link]]) {
            ImageViewController *controller = [[ImageViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            
            [self presentModalViewController:navigationController animated:YES];
            
            controller.url = [NSURL URLWithString:theLinkZone.link];
        } else if([hashtagRegex numberOfMatchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])] > 0) {
            NSArray *matches = [hashtagRegex matchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])];
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            NSString *hashtag = [theLinkZone.link substringWithRange:[result rangeAtIndex:1]];
            
            PostStreamViewController *controller = [[PostStreamViewController alloc] init];
            HashtagPostStreamConfiguration *configuration = [[HashtagPostStreamConfiguration alloc] init];
            configuration.hashtag = hashtag;
            controller.postStreamConfiguration = configuration;
            controller.title = [NSString stringWithFormat:@"#%@", configuration.hashtag];
            [self.navigationController pushViewController:controller animated:YES];
        } else if([postRegex numberOfMatchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])] > 0) {
            NSArray *matches = [postRegex matchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])];
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            NSString *postID = [theLinkZone.link substringWithRange:[result rangeAtIndex:1]];
            
            ReplyPostStreamConfiguration *configuration = [[ReplyPostStreamConfiguration alloc] init];
            configuration.postID = postID;
            
            PostStreamViewController *viewController = [[PostStreamViewController alloc] init];
            viewController.focusedPostID = postID;
            viewController.title = @"Thread";
            viewController.postStreamConfiguration = configuration;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if([shortPostRegex numberOfMatchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])] > 0) {
            NSArray *matches = [shortPostRegex matchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])];
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            NSString *postID = [theLinkZone.link substringWithRange:[result rangeAtIndex:1]];
            
            ReplyPostStreamConfiguration *configuration = [[ReplyPostStreamConfiguration alloc] init];
            configuration.postID = postID;
            NSLog(@"%@", postID);
            
            PostStreamViewController *viewController = [[PostStreamViewController alloc] init];
            viewController.focusedPostID = postID;
            viewController.title = @"Thread";
            viewController.postStreamConfiguration = configuration;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if([userRegex numberOfMatchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])] > 0) {
            NSArray *matches = [userRegex matchesInString:theLinkZone.link options:0 range:NSMakeRange(0, [theLinkZone.link length])];
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            NSString *userID = [theLinkZone.link substringWithRange:[result rangeAtIndex:1]];
            
            UserViewController *controller = [[UserViewController alloc] init];
            controller.userID = [NSString stringWithFormat:@"@%@", userID];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            WebBrowserViewController *controller = [[WebBrowserViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            
            [self presentModalViewController:navigationController animated:YES];
            
            [controller openURL:[NSURL URLWithString:theLinkZone.link]];
        }
    }
}

- (BOOL)tableViewCell:(PostTableViewCell *)theTableViewCell longPressedLinkZone:(LinkZone *)theLinkZone
{
    if(theLinkZone.type == LinkZoneTypeLink) {
        [self collapseTappedCell];
        
        [URLMenu showMenuForURL:[NSURL URLWithString:theLinkZone.link] title:theLinkZone.link viewController:self inView:self.view.window];
        
        return YES;
    }
    
    return NO;
}

- (void)tableViewCellPickedReply:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self replyToTappedPost];
}

- (void)tableViewCellPickedRepost:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self repostTappedPost];
}

- (void)tableViewCellPickedNativeRepost:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self nativeRepostTappedPost];
}

- (void)tableViewCellPickedDelete:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self deleteTappedPost];
}

- (void)tableViewCellPickedCopy:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self copyTappedPost];
}

- (void)tableViewCellPickedCopyURLOfPost:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self copyURLOfTappedPost];
}

- (void)tableViewCellPickedReplyAll:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self replyToAllInTappedPost];
}

- (void)tableViewCellPickedViewProfile:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self viewProfile];
}

- (void)tableViewCellPickedMailPost:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self mailPost];
}

- (void)tableViewCellPickedStar:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self starTappedPost];
}

- (void)tableViewCellPickedUnstar:(PostTableViewCell *)theTableViewCell
{
    [self collapseTappedCell];
    [self unstarTappedPost];
}

#pragma mark -
#pragma mark LoadMoreTableViewCellDelegate
- (void)loadMoreTableViewCellTapped:(LoadMoreTableViewCell *)theCell
{
    if(!self.shouldIgnoreActionTriggers) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:theCell];
        [self.postStreamDataController loadMissingCellsFromBreakAtIndex:indexPath.row];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark NewPostCountViewDelegate
- (void)newPostCountViewRequestedScrollToUnread:(NewPostCountView *)theNewPostCountView
{
    __block CGFloat top = 0;
    [self.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [[self.cellHeights objectAtIndex:idx] floatValue];
        if(obj == [NSNull null]) {
            top += height;
            return;
        }
        
        Post *post = obj;
        if([post.postID isEqual:self.postStreamDataController.data.lastReadPostID]) {
            *stop = YES;
        } else {
            top += height;
        }
    }];
    
    [self.tableView setContentOffset:CGPointMake(0, top - 33) animated:YES];
}
@end
