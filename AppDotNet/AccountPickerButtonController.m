//
//  AccountPickerButtonController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AccountPickerButtonController.h"
#import "AccountPickerViewController.h"
#import "APIAuthorization.h"
#import "AccountPickerButton.h"
#import "AccountPickerButton.h"

@interface AccountPickerButtonController()
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSMutableArray *viewControllers;

- (void)updateViewController:(UIViewController *)theViewController;
@end

@implementation AccountPickerButtonController
+ (AccountPickerButtonController *)sharedAccountPickerButtonController
{
    static AccountPickerButtonController *sharedController = nil;
    
    if(sharedController == nil) {
        sharedController = [[AccountPickerButtonController alloc] init];
    }
    
    return sharedController;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.viewControllers = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenDidChange:) name:APIAuthorizationAccessTokenDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileDidChange:) name:APIAuthorizationProfileDidChangeNotification object:nil];
    }
    return self;
}

- (void)accessTokenDidChange:(NSNotification *)notification
{
    for(UIViewController *viewController in self.viewControllers) {
        [self updateViewController:viewController];
    }
}

- (void)profileDidChange:(NSNotification *)notification
{
    for(UIViewController *viewController in self.viewControllers) {
        [self updateViewController:viewController];
    }
    
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (void)addViewController:(UIViewController *)theViewController
{
    [self.viewControllers addObject:theViewController];
    
    [self updateViewController:theViewController];
}

- (void)updateViewController:(UIViewController *)theViewController
{
    if([[[APIAuthorization sharedAPIAuthorization] profiles] count] > 1) {
        APIAuthorizationProfile *profile = [[APIAuthorization sharedAPIAuthorization] currentProfile];
        UIImage *image = [[APIAuthorization sharedAPIAuthorization] imageForProfile:profile];
        
        if(image) {
            AccountPickerButton *button = [[AccountPickerButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [button addTarget:self action:@selector(showAccounts:) forControlEvents:UIControlEventTouchUpInside];
            button.image = image;
            theViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        } else {
            theViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Accounts" style:UIBarButtonItemStyleBordered target:self action:@selector(showAccounts:)];
        }
    } else {
        theViewController.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)showAccounts:(AccountPickerButton *)sender
{
    AccountPickerViewController *controller = [[AccountPickerViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    for(UIViewController *checkController in self.viewControllers) {
        if(checkController.navigationItem.leftBarButtonItem.customView == (UIView *)sender) {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
                
                controller.navigationItem.leftBarButtonItem = nil;
                
                self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
                [self.popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [checkController presentModalViewController:navigationController animated:YES];
            }
            return;
        } else if(checkController.navigationItem.leftBarButtonItem == (UIBarButtonItem *)sender) {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
                
                controller.navigationItem.leftBarButtonItem = nil;
                
                self.popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
                [self.popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [checkController presentModalViewController:navigationController animated:YES];
            }
            return;
        }
    }
}
@end
