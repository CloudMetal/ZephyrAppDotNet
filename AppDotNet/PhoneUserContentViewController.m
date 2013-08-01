//
//  PhoneUserContentViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PhoneUserContentViewController.h"
#import "UserContentViewController+NIB.h"
#import "LabeledDividerView.h"
#import "AuthenticatedUser.h"

@interface PhoneUserContentViewController()
@property (nonatomic, strong) IBOutlet LabeledDividerView *followsYouLabeledDividerView;
@property (nonatomic, strong) IBOutlet LabeledDividerView *preBioLabeledDividerView;
@property (nonatomic, strong) IBOutlet LabeledDividerView *postBioLabeledDividerView;

- (void)relayout;
@end

@implementation PhoneUserContentViewController
- (id)init
{
    self = [super initWithNibName:@"PhoneUserContentViewController" bundle:nil];
    if(self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark Overrides
- (void)repopulate
{
    [super repopulate];
    
    if(self.user.followsYou) {
        self.followsYouLabeledDividerView.text = @"FOLLOWS YOU";
    } else {
        self.followsYouLabeledDividerView.text = nil;
    }
    
    [self relayout];
}

#pragma mark -
#pragma mark Private API
- (void)relayout
{
    CGFloat top = self.toggleFollowButton.frame.origin.y;
    CGFloat elementSpacing = 10;
    
    if([self.user.userID isEqual:[[[AuthenticatedUser sharedAuthenticatedUser] user] userID]]) {
        self.toggleFollowButton.hidden = YES;
        top += 5;
    } else {
        self.toggleFollowButton.hidden = NO;
        top += self.toggleFollowButton.frame.size.height + elementSpacing;
    }
    
    self.preBioLabeledDividerView.frame = CGRectMake(self.preBioLabeledDividerView.frame.origin.x, top, self.preBioLabeledDividerView.frame.size.width, self.preBioLabeledDividerView.frame.size.height);
    top += self.preBioLabeledDividerView.frame.size.height + elementSpacing;
    
    self.bioLabel.frame = CGRectMake(self.bioLabel.frame.origin.x, top, self.bioLabel.frame.size.width, [self.bioLabel.text sizeWithFont:self.bioLabel.font constrainedToSize:CGSizeMake(self.bioLabel.frame.size.width, 1024) lineBreakMode:UILineBreakModeWordWrap].height);
    top += self.bioLabel.frame.size.height + elementSpacing;
    
    self.postBioLabeledDividerView.frame = CGRectMake(self.postBioLabeledDividerView.frame.origin.x, top, self.postBioLabeledDividerView.frame.size.width, self.postBioLabeledDividerView.frame.size.height);
    top += self.preBioLabeledDividerView.frame.size.height + elementSpacing;
    
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
    
    self.joinDateLabel.frame = CGRectMake(self.joinDateLabel.frame.origin.x, top, self.joinDateLabel.frame.size.width, self.joinDateLabel.frame.size.height);
    top += self.joinDateLabel.frame.size.height;
    
    self.memberNumberLabel.frame = CGRectMake(self.memberNumberLabel.frame.origin.x, top, self.memberNumberLabel.frame.size.width, self.memberNumberLabel.frame.size.height);
    top += self.memberNumberLabel.frame.size.height + elementSpacing;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, top);
    self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, top);
}
@end
