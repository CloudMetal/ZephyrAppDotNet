//
//  UserViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserViewController.h"
#import "PostStreamViewController.h"
#import "UserPostStreamConfiguration.h"
#import "UserMentionStreamConfiguration.h"
#import "UserStarStreamConfiguration.h"
#import "UserListViewController.h"
#import "UserFollowersConfiguration.h"
#import "UserFollowingConfiguration.h"
#import "API.h"
#import "AvatarPool.h"
#import "AuthenticatedUser.h"
#import "ComposeViewController.h"
#import "LabeledDividerView.h"
#import "AvatarImageView.h"
#import "ImageViewController.h"
#import "PadUserContentViewController.h"
#import "PhoneUserContentViewController.h"
#import "ActivityNotificationView.h"

@interface UserViewController() <VDownloadDelegate, UserContentViewControllerDelegate>
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) UserContentViewController *contentViewController;

@property (nonatomic, copy) NSURL *backgroundImageURL;
@property (nonatomic, copy) NSURL *avatarImageURL;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) VDownload *backgroundDownload;
@property (nonatomic, strong) VDownload *avatarDownload;

@property (nonatomic) BOOL reloadingUser;

- (void)finishInit;
- (void)registerObservers;
- (void)unregisterObservers;
- (void)reloadUser;
- (void)relayout;
@end

@implementation UserViewController
- (id)init
{
    self = [super initWithNibName:@"UserViewController" bundle:nil];
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
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.contentViewController = [[PadUserContentViewController alloc] init];
    } else {
        self.contentViewController = [[PhoneUserContentViewController alloc] init];
    }
    self.contentViewController.delegate = self;
    
    self.userID = @"me";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(compose:)];
    
    [self registerObservers];
}

- (void)dealloc
{
    [self.backgroundDownload cancel];
    self.backgroundDownload = nil;
    
    [self.avatarDownload cancel];
    self.avatarDownload = nil;
    
    [self unregisterObservers];
}

- (void)viewDidLoad
{
    self.loadingView.frame = self.view.bounds;
    [self.view addSubview:self.loadingView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.backgroundView.image = [self.backgroundView.image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    //UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    //[self.avatarImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadUser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"user"]) {
        self.contentViewController.user = self.user;
        
        if(self.user != nil) {
            [self.loadingView removeFromSuperview];
            
            [self addChildViewController:self.contentViewController];
            [self.contentViewController didMoveToParentViewController:self];
            self.contentViewController.view.frame = self.view.bounds;
            [self.view addSubview:self.contentViewController.view];
            
            if(![self.user.coverImage.url isEqual:self.backgroundImageURL]) {
                [self.backgroundDownload cancel];
                self.backgroundDownload.delegate = nil;
                self.backgroundDownload = nil;
                
                self.contentViewController.profileBackgroundImage = nil;
                self.backgroundImageURL = self.user.coverImage.url;
            }
            
            if(![self.user.avatarImage.url isEqual:self.avatarImageURL]) {
                [self.avatarDownload cancel];
                self.avatarDownload.delegate = nil;
                self.avatarDownload = nil;
                self.avatarImageURL = self.user.avatarImage.url;
                
                if(self.user.avatarImage.url) {
                    CGSize size = self.contentViewController.avatarSize;
                    size = CGSizeMake(size.width * [[UIScreen mainScreen] scale], size.height * [[UIScreen mainScreen] scale]);
                    
                    NSString *urlString = [self.user.avatarImage.url absoluteString];
                    urlString = [urlString stringByAppendingFormat:@"?w=%i&h=%i", (NSUInteger)size.width, (NSUInteger)size.height];
                    NSURL *url = [NSURL URLWithString:urlString];
                    
                    self.avatarDownload = [VDownload startDownloadWithURL:url delegate:self];
                }
            }
        }
        
        [self relayout];
        
        if(self.user != nil && [self.userID isEqualToString:@"me"]) {
            APIAuthorizationProfile *profile = [[APIAuthorization sharedAPIAuthorization] currentProfile];
            profile.userID = self.user.userID;
            profile.user = self.user.name;
            profile.userName = self.user.userName;
        }
    }
}

#pragma mark -
#pragma mark Notifications
- (void)avatarPoolFinishedDownload:(NSNotification *)notification
{
    if(!self.avatarImage) {
        [self relayout];
    }
}

#pragma mark -
#pragma mark Actions
- (void)compose:(id)sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    if(![self.user.userID isEqual:[[[AuthenticatedUser sharedAuthenticatedUser] user] userID]]) {
        if(self.user.userName != nil) {
            composeViewController.defaultText = [NSString stringWithFormat:@"@%@ ", self.user.userName];
        }
    }
    [composeViewController presentInViewController:self];
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"user" options:0 context:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarPoolFinishedDownload:) name:AvatarPoolFinishedDownloadNotification object:nil];
}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"user"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AvatarPoolFinishedDownloadNotification object:nil];
}

- (void)reloadUser
{
    if(self.reloadingUser) {
        return;
    }
    
    [APIUserGet getUser:self.userID completionHandler:^(User *user, NSError *error) {
        self.user = user;
    }];
}

- (void)relayout
{
    if(!self.contentViewController.profileBackgroundImage && !self.backgroundDownload) {
        if(self.user.coverImage.url) {
            NSInteger width = self.contentViewController.profileBackgroundSize.width * [[UIScreen mainScreen] scale];
            NSInteger height = self.contentViewController.profileBackgroundSize.height * [[UIScreen mainScreen] scale];
            CGSize containerSize = CGSizeMake(width, height);
            CGSize nativeImageSize = CGSizeMake(self.user.coverImage.width, self.user.coverImage.height);
            CGSize imageSize = CGSizeZero;
            CGFloat containerAspectRatio = containerSize.width / containerSize.height;
            CGFloat nativeAspectRatio = nativeImageSize.width / nativeImageSize.height;
            
            if(containerAspectRatio >= nativeAspectRatio) {
                CGFloat scale = nativeImageSize.width / containerSize.width;
                imageSize = CGSizeMake(nativeImageSize.width / scale, nativeImageSize.height / scale);
            } else {
                CGFloat scale = nativeImageSize.height / containerSize.height;
                imageSize = CGSizeMake(nativeImageSize.width / scale, nativeImageSize.height / scale);
            }
            
            NSString *urlString = [self.user.coverImage.url absoluteString];
            urlString = [urlString stringByAppendingFormat:@"?w=%i&h=%i", (NSUInteger)imageSize.width, (NSUInteger)imageSize.height];
            NSURL *url = [NSURL URLWithString:urlString];
            
            self.backgroundDownload = [VDownload startDownloadWithURL:url delegate:self];
        }
    }
    
    self.navigationItem.title = self.user.name;
    
    /*if(self.avatarImage) {
        self.avatarImageView.image = self.avatarImage;
        
        if([self.userID isEqualToString:@"me"]) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(44, 44), YES, 0);
            [self.avatarImage drawInRect:CGRectMake(0, 0, 44, 44)];
            
            APIAuthorizationProfile *profile = [[APIAuthorization sharedAPIAuthorization] currentProfile];
            [[APIAuthorization sharedAPIAuthorization] setImage:UIGraphicsGetImageFromCurrentImageContext() forProfile:profile];
            
            UIGraphicsEndImageContext();
        }
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"avatar-placeholder.png"];
    }*/
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    if(theDownload == self.backgroundDownload) {
        self.backgroundDownload = nil;
        
        UIImage *image = [UIImage imageWithData:theData];
        if(image) {
            self.contentViewController.profileBackgroundImage = image;
        }
    } else if(theDownload == self.avatarDownload) {
        self.avatarDownload = nil;
        
        UIImage *image = [UIImage imageWithData:theData];
        if(image) {
            self.avatarImage = image;
            self.contentViewController.avatarImage = image;
        }
    }
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    if(theDownload == self.backgroundDownload) {
        self.backgroundDownload = nil;
    } else if(theDownload == self.avatarDownload) {
        self.avatarDownload = nil;
    }
}

#pragma mark -
#pragma mark UserContentViewControllerDelegate
- (void)userContentViewControllerRequestsViewFollowers:(UserContentViewController *)theUserContentViewController
{
    UserListViewController *controller = [[UserListViewController alloc] init];
    UserFollowersConfiguration *configuration = [[UserFollowersConfiguration alloc] init];
    configuration.userID = self.userID;
    controller.configuration = configuration;
    controller.title = @"Followers";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)userContentViewControllerRequestsViewFollowing:(UserContentViewController *)theUserContentViewController
{
    UserListViewController *controller = [[UserListViewController alloc] init];
    UserFollowingConfiguration *configuration = [[UserFollowingConfiguration alloc] init];
    configuration.userID = self.userID;
    controller.configuration = configuration;
    controller.title = @"Following";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)userContentViewControllerRequestsViewPosts:(UserContentViewController *)theUserContentViewController
{
    PostStreamViewController *controller = [[PostStreamViewController alloc] init];
    UserPostStreamConfiguration *configuration = [[UserPostStreamConfiguration alloc] init];
    configuration.userID = self.user.userID;
    controller.postStreamConfiguration = configuration;
    controller.title = [NSString stringWithFormat:@"%@'s Posts", self.user.name];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)userContentViewControllerRequestsViewMentions:(UserContentViewController *)theUserContentViewController
{
    PostStreamViewController *controller = [[PostStreamViewController alloc] init];
    UserMentionStreamConfiguration *configuration = [[UserMentionStreamConfiguration alloc] init];
    configuration.userID = self.user.userID;
    controller.postStreamConfiguration = configuration;
    controller.title = [NSString stringWithFormat:@"@%@", self.user.userName];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)userContentViewControllerRequestsViewStars:(UserContentViewController *)theUserContentViewController
{
    PostStreamViewController *controller = [[PostStreamViewController alloc] init];
    UserStarStreamConfiguration *configuration = [[UserStarStreamConfiguration alloc] init];
    configuration.userID = self.user.userID;
    controller.postStreamConfiguration = configuration;
    controller.title = [NSString stringWithFormat:@"%@'s Stars", self.user.userName];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)userContentViewControllerRequestsViewAvatar:(UserContentViewController *)theUserContentViewController
{
    if(self.user.avatarImage.url) {
        ImageViewController *controller = [[ImageViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self presentModalViewController:navigationController animated:YES];
        
        controller.url = self.user.avatarImage.url;
    }
}

- (void)userContentViewControllerRequestsToggleFollow:(UserContentViewController *)theUserContentViewController
{
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    
    if(self.user.youFollow) {
        [APIUserUnfollow unfollowUserWithID:self.user.userID completionHandler:^(User *user, NSError *error) {
            notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
            [notificationView dismissAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APIUserFollowDidFinishNotification object:nil];
            
            [self reloadUser];
        }];
    } else {
        [APIUserFollow followUserWithID:self.user.userID completionHandler:^(User *user, NSError *error) {
            notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
            [notificationView dismissAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APIUserUnfollowDidFinishNotification object:nil];
            
            [self reloadUser];
        }];
    }
}

- (void)userContentViewControllerRequestsToggleMute:(UserContentViewController *)theUserContentViewController
{
    ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
    [notificationView showInWindow:self.view.window animated:YES];
    
    if(self.user.youMuted) {
        [APIUserUnmute unmuteUserWithID:self.user.userID completionHandler:^(User *user, NSError *error) {
            notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
            [notificationView dismissAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APIUserUnmuteDidFinishNotification object:nil];
            
            [self reloadUser];
        }];
    } else {
        [APIUserMute muteUserWithID:self.user.userID completionHandler:^(User *user, NSError *error) {
            notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
            [notificationView dismissAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APIUserMuteDidFinishNotification object:nil];
            
            [self reloadUser];
        }];
    }
}
@end
