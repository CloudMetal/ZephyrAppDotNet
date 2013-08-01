//
//  PadUserContentViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PadUserContentViewController.h"
#import "UserContentViewController+NIB.h"
#import "AuthenticatedUser.h"

@interface PadUserContentViewController()
@property (nonatomic, strong) IBOutlet UIImageView *statBoxBackgroundView;

- (void)relayout;
@end

@implementation PadUserContentViewController
- (id)init
{
    self = [super initWithNibName:@"PadUserContentViewController" bundle:nil];
    if(self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark Overrides
- (void)repopulate
{
    [super repopulate];
    
    [self relayout];
}

#pragma mark -
#pragma mark Private API
- (void)relayout
{
    CGFloat top = self.statBoxBackgroundView.frame.origin.y + self.statBoxBackgroundView.frame.size.height;
    CGFloat elementSpacing = 10;
    
    top += elementSpacing;
    top += elementSpacing;
    
    self.bioLabel.frame = CGRectMake(self.bioLabel.frame.origin.x, top, self.bioLabel.frame.size.width, [self.bioLabel.text sizeWithFont:self.bioLabel.font constrainedToSize:CGSizeMake(self.bioLabel.frame.size.width, 1024) lineBreakMode:UILineBreakModeWordWrap].height);
    top += self.bioLabel.frame.size.height + elementSpacing;
    
    top += elementSpacing;
    
    if([self.user.userID isEqual:[[[AuthenticatedUser sharedAuthenticatedUser] user] userID]]) {
        self.toggleFollowButton.hidden = YES;
    } else {
        self.toggleFollowButton.hidden = NO;
        
        self.toggleFollowButton.frame = CGRectMake(self.toggleFollowButton.frame.origin.x, top, self.toggleFollowButton.frame.size.width, self.toggleFollowButton.frame.size.height);
        top += self.toggleFollowButton.frame.size.height + elementSpacing;
    }
    
    self.mentionsButton.frame = CGRectMake(self.mentionsButton.frame.origin.x, top, self.mentionsButton.frame.size.width, self.mentionsButton.frame.size.height);
    top += self.mentionsButton.frame.size.height + elementSpacing;
    
    self.starsButton.frame = CGRectMake(self.starsButton.frame.origin.x, top, self.starsButton.frame.size.width, self.starsButton.frame.size.height);
    top += self.starsButton.frame.size.height + elementSpacing;
    
    if([self.user.userID isEqual:[[[AuthenticatedUser sharedAuthenticatedUser] user] userID]]) {
        self.toggleMuteButton.hidden = YES;
    } else {
        self.toggleMuteButton.hidden = NO;
        
        self.toggleMuteButton.frame = CGRectMake(self.toggleMuteButton.frame.origin.x, top, self.toggleMuteButton.frame.size.width, self.toggleMuteButton.frame.size.height);
        top += self.toggleMuteButton.frame.size.height + elementSpacing;
    }
    
    top += elementSpacing;
    
    self.joinDateLabel.frame = CGRectMake(self.joinDateLabel.frame.origin.x, top, self.joinDateLabel.frame.size.width, self.joinDateLabel.frame.size.height);
    top += self.joinDateLabel.frame.size.height;
    
    self.memberNumberLabel.frame = CGRectMake(self.memberNumberLabel.frame.origin.x, top, self.memberNumberLabel.frame.size.width, self.memberNumberLabel.frame.size.height);
    top += self.memberNumberLabel.frame.size.height + elementSpacing;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, top);
    self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, top);

}
@end
