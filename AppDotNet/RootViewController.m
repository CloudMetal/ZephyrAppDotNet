//
//  RootViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "RootViewController.h"
#import "DrawerViewController.h"
#import "AuthorizationGateViewController.h"
#import "TabBarViewController.h"
#import "PadTabBarViewController.h"
#import "WelcomeViewController.h"
#import "APIAuthorization.h"
#import "ComposeViewController.h"
#import "PostTableViewCell.h"
#import "UserSettings.h"
#import "AccountPickerButtonController.h"

#import "UserMentionStreamConfiguration.h"

@interface RootViewController ()
@property (nonatomic, strong) IBOutlet UserMentionStreamConfiguration *userMentionStreamConfiguration;

@property (nonatomic, strong) IBOutlet UINavigationController *unifiedViewController;
@property (nonatomic, strong) IBOutlet UINavigationController *streamViewController;
@property (nonatomic, strong) IBOutlet UINavigationController *mentionsViewController;
@property (nonatomic, strong) IBOutlet UINavigationController *globalViewController;
@property (nonatomic, strong) IBOutlet UINavigationController *userViewController;
@property (nonatomic, strong) IBOutlet UIViewController *searchViewController;
@property (nonatomic, strong) IBOutlet UIViewController *settingsViewController;

@property (nonatomic, strong) IBOutlet UIViewController *drawerViewController;
@property (nonatomic, strong) IBOutlet UITabBarController *mainInterfaceViewController;
@property (nonatomic, strong) IBOutlet TabBarViewController *tabBarViewController;
@property (nonatomic, strong) IBOutlet PadTabBarViewController *padTabBarViewController;
@property (nonatomic, strong) AuthorizationGateViewController *authorizationGateViewController;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeOpenGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeClosedGestureRecognizer;

@property (nonatomic) BOOL showingDrawer;
@property (nonatomic, strong) UIButton *hideDrawerButton;

- (void)registerObservers;
- (void)unregisterObservers;

- (void)setTabBarViewControllers;

- (IBAction)showDrawer:(id)sender;
@end

@implementation RootViewController
- (id)init
{
    self = [super init];
    if(self) {
        [self registerObservers];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)loadView
{
    [[NSBundle mainBundle] loadNibNamed:@"MainInterface" owner:self options:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
    view.backgroundColor = [UIColor blackColor];
    self.view = view;
    
    self.userMentionStreamConfiguration.savesPosts = YES;
    
    self.unifiedViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-stream.png"];
    self.streamViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-stream.png"];
    self.mentionsViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-mentions.png"];
    self.globalViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-global.png"];
    self.userViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-me.png"];
    self.searchViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-search.png"];
    self.settingsViewController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-settings.png"];
    
    self.unifiedViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-stream-pressed.png"];
    self.streamViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-stream-pressed.png"];
    self.mentionsViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-mentions-pressed.png"];
    self.globalViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-global-pressed.png"];
    self.userViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-me-pressed.png"];
    self.searchViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-search-pressed.png"];
    self.settingsViewController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-settings-pressed.png"];
    
    self.unifiedViewController.adnTabBarItem.title = @"Stream";
    self.streamViewController.adnTabBarItem.title = @"Stream";
    self.mentionsViewController.adnTabBarItem.title = @"Mentions";
    self.globalViewController.adnTabBarItem.title = @"Global";
    self.userViewController.adnTabBarItem.title = @"Profile";
    self.searchViewController.adnTabBarItem.title = @"Search";
    self.settingsViewController.adnTabBarItem.title = @"Settings";
    
    self.unifiedViewController.adnTabBarItem.showsNewPostIndicator = YES;
    self.streamViewController.adnTabBarItem.showsNewPostIndicator = YES;
    self.mentionsViewController.adnTabBarItem.showsNewPostIndicator = YES;
    //self.globalViewController.adnTabBarItem.showsNewPostIndicator = YES;
    
    [self setTabBarViewControllers];
    
    /*[self addChildViewController:self.drawerViewController];
    [self.drawerViewController didMoveToParentViewController:self];
    
    self.drawerViewController.view.frame = view.bounds;
    self.drawerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;*/
    //[view addSubview:self.drawerViewController.view];
    
    [self addChildViewController:self.mainInterfaceViewController];
    [self.mainInterfaceViewController didMoveToParentViewController:self];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self addChildViewController:self.padTabBarViewController];
        [self.padTabBarViewController didMoveToParentViewController:self];
    } else {
        [self addChildViewController:self.tabBarViewController];
        [self.tabBarViewController didMoveToParentViewController:self];
    }
    
    self.mainInterfaceViewController.view.frame = view.bounds;
    self.mainInterfaceViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //[view addSubview:self.mainInterfaceViewController.view];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.padTabBarViewController.view.frame = view.bounds;
        self.padTabBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:self.padTabBarViewController.view];
    } else {
        self.tabBarViewController.view.frame = view.bounds;
        self.tabBarViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:self.tabBarViewController.view];
    }
    
    self.swipeOpenGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOpen:)];
    self.swipeOpenGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    //[view addGestureRecognizer:self.swipeOpenGestureRecognizer];
    
    self.swipeClosedGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeClosed:)];
    self.swipeClosedGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    //[view addGestureRecognizer:self.swipeClosedGestureRecognizer];
    
    self.swipeOpenGestureRecognizer.enabled = YES;
    self.swipeClosedGestureRecognizer.enabled = NO;
    
    if(![[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        self.authorizationGateViewController = [[AuthorizationGateViewController alloc] init];
        
        [self addChildViewController:self.authorizationGateViewController];
        [self.authorizationGateViewController didMoveToParentViewController:self];
        
        self.authorizationGateViewController.view.frame = view.bounds;
        self.authorizationGateViewController.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:self.authorizationGateViewController.view];
    }
    
    [[AccountPickerButtonController sharedAccountPickerButtonController] addViewController:[self.unifiedViewController.viewControllers objectAtIndex:0]];
    [[AccountPickerButtonController sharedAccountPickerButtonController] addViewController:[self.streamViewController.viewControllers objectAtIndex:0]];
    [[AccountPickerButtonController sharedAccountPickerButtonController] addViewController:[self.mentionsViewController.viewControllers objectAtIndex:0]];
    [[AccountPickerButtonController sharedAccountPickerButtonController] addViewController:[self.globalViewController.viewControllers objectAtIndex:0]];
    [[AccountPickerButtonController sharedAccountPickerButtonController] addViewController:[self.userViewController.viewControllers objectAtIndex:0]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if([WelcomeViewController shouldShowWelcomeView]) {
        WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
        [self presentModalViewController:navigationController animated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"showUnifiedStream"]) {
        [self setTabBarViewControllers];
    }
}

#pragma mark -
#pragma mark Actions
- (void)swipeClosed:(UISwipeGestureRecognizer *)recognizer
{
    //[self showDrawer:self];
}

- (void)swipeOpen:(UISwipeGestureRecognizer *)recognizer
{
    //[self showDrawer:self];
}

- (IBAction)compose:(id)sender
{
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    [composeViewController presentInViewController:self];
}

- (IBAction)showDrawer:(id)sender
{
    NSTimeInterval animationDuration = 0.3;
    
    if(self.showingDrawer) {
        [self.hideDrawerButton removeFromSuperview];
        
        self.swipeOpenGestureRecognizer.enabled = YES;
        self.swipeClosedGestureRecognizer.enabled = NO;
        
        self.showingDrawer = NO;
        [UIView animateWithDuration:animationDuration animations:^{
            self.mainInterfaceViewController.view.transform = CGAffineTransformIdentity;
        }];
    } else {
        if(!self.hideDrawerButton) {
            self.hideDrawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.hideDrawerButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [self.hideDrawerButton addTarget:self action:@selector(showDrawer:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.hideDrawerButton.frame = self.mainInterfaceViewController.view.bounds;
        [self.mainInterfaceViewController.view addSubview:self.hideDrawerButton];
        
        self.swipeOpenGestureRecognizer.enabled = NO;
        self.swipeClosedGestureRecognizer.enabled = YES;
        
        self.showingDrawer = YES;
        [UIView animateWithDuration:animationDuration animations:^{
            self.mainInterfaceViewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - 44, 0);
        }];
    }
}

#pragma mark -
#pragma mark Public API
- (void)showMentionTab
{
    [self.mainInterfaceViewController setSelectedIndex:1];
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenDidChange:) name:APIAuthorizationAccessTokenDidChangeNotification object:[APIAuthorization sharedAPIAuthorization]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipeOpen:) name:PostTableViewCellSwipedRightNotification object:nil];
    
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"showUnifiedStream" options:0 context:0];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIAuthorizationAccessTokenDidChangeNotification object:[APIAuthorization sharedAPIAuthorization]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PostTableViewCellSwipedRightNotification object:nil];
    
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"showUnifiedStream"];
}

- (void)setTabBarViewControllers
{
    static UIViewController *originalSearchViewController = nil;
    static UIViewController *originalSettingsViewController = nil;
    
    if(originalSearchViewController == nil) {
        originalSearchViewController = [[((UINavigationController *)self.searchViewController) viewControllers] objectAtIndex:0];
        originalSettingsViewController = [[((UINavigationController *)self.settingsViewController) viewControllers] objectAtIndex:0];
    }
    
    UINavigationController *newSearchNavigationController = [[UINavigationController alloc] initWithRootViewController:originalSearchViewController];
    newSearchNavigationController.adnTabBarItem.image = self.searchViewController.adnTabBarItem.image;
    newSearchNavigationController.adnTabBarItem.selectedImage = self.searchViewController.adnTabBarItem.selectedImage;
    newSearchNavigationController.adnTabBarItem.title = self.searchViewController.adnTabBarItem.title;
    self.searchViewController = newSearchNavigationController;
    
    UINavigationController *newSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController:originalSettingsViewController];
    newSettingsNavigationController.adnTabBarItem.image = self.settingsViewController.adnTabBarItem.image;
    newSettingsNavigationController.adnTabBarItem.selectedImage = self.settingsViewController.adnTabBarItem.selectedImage;
    newSettingsNavigationController.adnTabBarItem.title = self.settingsViewController.adnTabBarItem.title;
    self.settingsViewController = newSettingsNavigationController;
    
    NSArray *viewControllers = nil;
    if([[UserSettings sharedUserSettings] showUnifiedStream] == NO) {
        viewControllers = @[
            self.streamViewController,
            self.mentionsViewController,
            self.globalViewController,
            self.userViewController,
            self.searchViewController,
            self.settingsViewController
        ];
    } else {
        viewControllers = @[
            self.unifiedViewController,
            self.globalViewController,
            self.userViewController,
            self.searchViewController,
            self.settingsViewController
        ];
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.padTabBarViewController view];
        self.padTabBarViewController.viewControllers = viewControllers;
    } else {
        self.tabBarViewController.viewControllers = viewControllers;
    }
}

#pragma mark -
#pragma mark Notifications
- (void)accessTokenDidChange:(NSNotification *)notification
{
    if(([[APIAuthorization sharedAPIAuthorization] currentProfile] == nil) && [[[APIAuthorization sharedAPIAuthorization] profiles] count] > 0) {
        [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:[[[APIAuthorization sharedAPIAuthorization] profiles] lastObject]];
    }
    
    if([[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        [self.authorizationGateViewController.view removeFromSuperview];
    } else {
        if(!self.authorizationGateViewController) {
            self.authorizationGateViewController = [[AuthorizationGateViewController alloc] init];
            
            [self addChildViewController:self.authorizationGateViewController];
            [self.authorizationGateViewController didMoveToParentViewController:self];
        }
        
        self.authorizationGateViewController.view.frame = self.view.bounds;
        self.authorizationGateViewController.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.authorizationGateViewController.view];
    }
}
@end
