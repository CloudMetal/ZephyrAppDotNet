//
//  AuthorizationGateViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AuthorizationGateViewController.h"
#import "AuthorizationViewController.h"

@interface AuthorizationGateViewController()
@property (nonatomic, strong) IBOutlet UIButton *authorizeButton;

@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

@property (nonatomic, strong) IBOutlet UIImageView *topImageView;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImageView;

@property (nonatomic, strong) IBOutlet UIImageView *iconView;

- (IBAction)authorize:(id)sender;
@end

@implementation AuthorizationGateViewController
- (id)init
{
    self = [super initWithNibName:@"AuthorizationGateViewController" bundle:nil];
    if(self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [self.authorizeButton setBackgroundImage:[[self.authorizeButton backgroundImageForState:UIControlStateNormal] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 7, 5, 7)] forState:UIControlStateNormal];
    [self.authorizeButton setBackgroundImage:[[self.authorizeButton backgroundImageForState:UIControlStateHighlighted] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 7, 5, 7)] forState:UIControlStateHighlighted];
    
    self.topImageView.image = [self.topImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    self.bottomImageView.image = [self.bottomImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.iconView.image = [UIImage imageNamed:@"welcome-zephyr-icon-iphone.png"];
    }
}

- (void)viewDidLayoutSubviews
{
    self.topView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height * 0.5);
    self.bottomView.frame = CGRectMake(0, self.containerView.bounds.size.height * 0.5, self.containerView.bounds.size.width, self.containerView.bounds.size.height * 0.5);
}

#pragma mark -
#pragma mark Actions
- (IBAction)authorize:(id)sender
{
    AuthorizationViewController *authorization = [[AuthorizationViewController alloc] init];
    [self presentModalViewController:authorization animated:YES];
}
@end
