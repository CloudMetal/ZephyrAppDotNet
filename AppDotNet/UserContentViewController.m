//
//  UserContentViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserContentViewController.h"
#import "UserContentViewController+NIB.h"

@interface UserContentViewController()
- (void)stylizeButton:(UIButton *)theButton normal:(UIImage *)normalImage highlighted:(UIImage *)highlightedImage;
@end

@implementation UserContentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [self addObserver:self forKeyPath:@"user" options:0 context:0];
        [self addObserver:self forKeyPath:@"avatarImage" options:0 context:0];
        [self addObserver:self forKeyPath:@"profileBackgroundImage" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"user"];
    [self removeObserver:self forKeyPath:@"avatarImage"];
    [self removeObserver:self forKeyPath:@"profileBackgroundImage"];
}

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    [self.avatarImageView addGestureRecognizer:tapGestureRecognizer];
    
    UIImage *blueImage = [UIImage imageNamed:@"follow-button.png"];
    UIImage *normalImage = [UIImage imageNamed:@"profile-action-btn.png"];
    UIImage *highlightedImage = [UIImage imageNamed:@"profile-action-btn-pressed.png"];
    
    [self stylizeButton:self.toggleFollowButton normal:blueImage highlighted:highlightedImage];
    [self stylizeButton:self.mentionsButton normal:normalImage highlighted:highlightedImage];
    [self stylizeButton:self.starsButton normal:normalImage highlighted:highlightedImage];
    [self stylizeButton:self.toggleMuteButton normal:normalImage highlighted:highlightedImage];
    
    [self repopulate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"user"]) {
        [self repopulate];
    } else if([keyPath isEqualToString:@"avatarImage"]) {
        [self repopulate];
    } else if([keyPath isEqualToString:@"profileBackgroundImage"]) {
        [self repopulate];
    }
}

#pragma mark -
#pragma mark Properties
- (CGSize)avatarSize
{
    return CGSizeMake(81, 81);
}

- (CGSize)profileBackgroundSize
{
    return self.profileBackgroundView.bounds.size;
}

#pragma mark -
#pragma mark Actions
- (IBAction)followers:(id)sender
{
    [self.delegate userContentViewControllerRequestsViewFollowers:self];
}

- (IBAction)following:(id)sender
{
    [self.delegate userContentViewControllerRequestsViewFollowing:self];
}

- (IBAction)posts:(id)sender
{
    [self.delegate userContentViewControllerRequestsViewPosts:self];
}

- (IBAction)mentions:(id)sender
{
    [self.delegate userContentViewControllerRequestsViewMentions:self];
}

- (IBAction)stars:(id)sender
{
    [self.delegate userContentViewControllerRequestsViewStars:self];
}

- (IBAction)toggleFollow:(id)sender
{
    [self.toggleFollowButton setEnabled:NO];
    [self.delegate userContentViewControllerRequestsToggleFollow:self];
}

- (IBAction)toggleMute:(id)sender
{
    [self.toggleMuteButton setEnabled:NO];
    [self.delegate userContentViewControllerRequestsToggleMute:self];
}

- (IBAction)avatarTapped:(id)sender
{
    [self.delegate userContentViewControllerRequestsViewAvatar:self];
}

#pragma mark -
#pragma mark Public API
- (void)repopulate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.toggleFollowButton.enabled = YES;
    self.toggleMuteButton.enabled = YES;
    
    self.prettyNameLabel.text = self.user.name;
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.userName];
    
    self.bioLabel.text = self.user.userDescription.text;
    self.joinDateLabel.text = [NSString stringWithFormat:@"Joined %@", [formatter stringFromDate:self.user.createdAt]];
    self.memberNumberLabel.text = [NSString stringWithFormat:@"Member #%@", self.user.userID];
    
    [self.followersButton setTitle:[numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:self.user.counts.countOfFollowers]] forState:UIControlStateNormal];
    [self.followingButton setTitle:[numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:self.user.counts.countOfFollowing]] forState:UIControlStateNormal];
    [self.postsButton setTitle:[numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:self.user.counts.countOfPosts]] forState:UIControlStateNormal];
    
    UIImage *blueImage = [UIImage imageNamed:@"follow-button.png"];
    UIImage *normalImage = [UIImage imageNamed:@"profile-action-btn.png"];
    UIImage *highlightedImage = [UIImage imageNamed:@"profile-action-btn-pressed.png"];
    
    if(self.user.youFollow) {
        [self.toggleFollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        [self stylizeButton:self.toggleFollowButton normal:normalImage highlighted:highlightedImage];
    } else {
        [self.toggleFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self stylizeButton:self.toggleFollowButton normal:blueImage highlighted:highlightedImage];
    }
    
    if(self.user.youMuted) {
        [self.toggleMuteButton setTitle:@"Unmute" forState:UIControlStateNormal];
    } else {
        [self.toggleMuteButton setTitle:@"Mute" forState:UIControlStateNormal];
    }
    
    if(self.avatarImage) {
        self.avatarImageView.image = self.avatarImage;
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"avatar-placeholder.png"];
    }
    
    if(self.profileBackgroundImage) {
        self.profileBackgroundView.image = self.profileBackgroundImage;
    } else {
        self.profileBackgroundView.image = nil;
    }
}

#pragma mark -
#pragma mark Private API
- (void)stylizeButton:(UIButton *)theButton normal:(UIImage *)normalImage highlighted:(UIImage *)highlightedImage
{
    [theButton setBackgroundImage:[normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 9, 5, 9)] forState:UIControlStateNormal];
    [theButton setBackgroundImage:[highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 9, 5, 9)] forState:UIControlStateHighlighted];
}
@end
