//
//  URLMenu.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "URLMenu.h"
#import <MessageUI/MessageUI.h>
#import "Instapaper.h"
#import "Pocket.h"

#import "InstapaperActivity.h"
#import "PocketActivity.h"
#import "SafariActivity.h"
#import "ChromeActivity.h"

#define kOpenInSafariButtonTitle @"Open in Safari"
#define kOpenInChromeButtonTitle @"Open in Chrome"
#define kCopyURLButtonTitle @"Copy Link to this Page"
#define kEmailURLButtonTitle @"Mail Link to this Page"
#define kSendToInstapaperButtonTitle @"Add Page to Instapaper"
#define kSendToPocketButtonTitle @"Add Page to Pocket"
#define kCancelButtonTitle @"Cancel"

static URLMenu *currentURLMenu = nil;

@interface URLMenu() <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *title;

- (id)initWithURL:(NSURL *)theURL;
@end

@implementation URLMenu
+ (void)showMenuForURL:(NSURL *)theURL title:(NSString *)theTitle viewController:(UIViewController *)theViewController fromToolbar:(UIToolbar *)theToolbar
{
    URLMenu *menu = [[URLMenu alloc] initWithURL:theURL];
    menu.title = theTitle;
    menu.viewController = theViewController;
    currentURLMenu = menu;
    
    if(menu.actionSheet) {
        [menu.actionSheet showFromToolbar:theToolbar];
    } else {
        [menu.viewController presentModalViewController:menu.activityViewController animated:YES];
    }
}

+ (void)showMenuForURL:(NSURL *)theURL title:(NSString *)theTitle viewController:(UIViewController *)theViewController inView:(UIView *)theView
{
    URLMenu *menu = [[URLMenu alloc] initWithURL:theURL];
    menu.title = theTitle;
    menu.viewController = theViewController;
    currentURLMenu = menu;
    
    if(menu.actionSheet) {
        [menu.actionSheet showInView:theView];
    } else {
        [menu.viewController presentModalViewController:menu.activityViewController animated:YES];
    }
}

- (id)initWithURL:(NSURL *)theURL
{
    self = [super init];
    if(self) {
        self.url = theURL;
        
        if([UIActivityViewController class]) {
            NSMutableArray *activities = [[NSMutableArray alloc] init];
            
            [activities addObject:[[SafariActivity alloc] init]];
            
            if([ChromeActivity canShareToChrome]) {
                [activities addObject:[[ChromeActivity alloc] init]];
            }
            
            if([[Instapaper sharedInstapaper] canShareToInstapaper]) {
                [activities addObject:[[InstapaperActivity alloc] init]];
            }
            
            if([[Pocket sharedPocket] canShareToPocket]) {
                [activities addObject:[[PocketActivity alloc] init]];
            }
            
            self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:activities];
        } else {
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [self.actionSheet addButtonWithTitle:kOpenInSafariButtonTitle];
            
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://www.googlechrome.com/"]]) {
                [self.actionSheet addButtonWithTitle:kOpenInChromeButtonTitle];
            }
            
            [self.actionSheet addButtonWithTitle:kCopyURLButtonTitle];
            
            if([MFMailComposeViewController canSendMail]) {
                [self.actionSheet addButtonWithTitle:kEmailURLButtonTitle];
            }
            
            if([[Instapaper sharedInstapaper] canShareToInstapaper]) {
                [self.actionSheet addButtonWithTitle:kSendToInstapaperButtonTitle];
            }
            
            if([[Pocket sharedPocket] canShareToPocket]) {
                [self.actionSheet addButtonWithTitle:kSendToPocketButtonTitle];
            }
            
            [self.actionSheet addButtonWithTitle:kCancelButtonTitle];
            [self.actionSheet setCancelButtonIndex:[self.actionSheet numberOfButtons] - 1];
        }
    }
    return self;
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:kOpenInSafariButtonTitle]) {
        [[UIApplication sharedApplication] openURL:self.url];
    } else if([buttonTitle isEqualToString:kOpenInChromeButtonTitle]) {
        NSString *scheme = self.url.scheme;
        
        NSString *chromeScheme = @"googlechrome";
        if([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }
        
        NSString *absoluteString = self.url.absoluteString;
        NSRange schemeRange = [absoluteString rangeOfString:@":"];
        NSString *urlWithoutScheme = [absoluteString substringFromIndex:schemeRange.location];
        NSString *chromeURLString = [chromeScheme stringByAppendingString:urlWithoutScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        [[UIApplication sharedApplication] openURL:chromeURL];
    } else if([buttonTitle isEqualToString:kCopyURLButtonTitle]) {
        [[UIPasteboard generalPasteboard] setString:self.url.absoluteString];
    } else if([buttonTitle isEqualToString:kEmailURLButtonTitle]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        
        [controller setSubject:self.title];
        [controller setMessageBody:self.url.absoluteString isHTML:NO];
        [self.viewController presentModalViewController:controller animated:YES];
    } else if([buttonTitle isEqualToString:kSendToInstapaperButtonTitle]) {
        [[Instapaper sharedInstapaper] sendURLToInstapaper:self.url];
    } else if([buttonTitle isEqualToString:kSendToPocketButtonTitle]) {
        [[Pocket sharedPocket] sendURLToPocket:self.url title:self.title];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
