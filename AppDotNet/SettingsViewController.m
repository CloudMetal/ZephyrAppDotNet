//
//  SettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <MessageUI/MessageUI.h>
#import "SettingsViewController.h"
#import "APIAuthorization.h"

#import "WelcomeViewController.h"
#import "InstapaperSettingsViewController.h"
#import "PocketSettingsViewController.h"
#import "CloudAppSettingsViewController.h"
#import "FeedbackViewController.h"
#import "NameDisplaySettingsViewController.h"
#import "FontSizeSettingsViewController.h"
#import "RefreshIntervalSettingsViewController.h"
#import "AccountsSettingsViewController.h"

#import "UserSettings.h"

#define kSectionAppNet 0
#define kSectionNet3000 1
#define kSectionNet3000B 2
#define kSectionWebSharing 3
#define kSectionPhotoSharing 4

@interface SettingsViewController() <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)finishInit;

- (void)registerObservers;
- (void)unregisterObservers;
@end

@implementation SettingsViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (id)init
{
    self = [super initWithNibName:@"SettingsViewController" bundle:nil];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (void)finishInit
{
    [self registerObservers];
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)viewDidLoad
{
    [self.tableView applyDarkGroupedStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"showUserName"] || [keyPath isEqualToString:@"bodyFontSize"] || [keyPath isEqualToString:@"refreshInterval"] || [keyPath isEqualToString:@"showDirectedPostsInUserStream"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"showUserName" options:0 context:0];
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"bodyFontSize" options:0 context:0];
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"refreshInterval" options:0 context:0];
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"showDirectedPostsInUserStream" options:0 context:0];
}

- (void)unregisterObservers
{
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"showUserName"];
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"bodyFontSize"];
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"refreshInterval"];
    [[UserSettings sharedUserSettings] removeObserver:self forKeyPath:@"showDirectedPostsInUserStream"];
}

#pragma mark -
#pragma mark Actions
- (void)pushNotificationSwitchChanged:(UISwitch *)theSwitch
{
    if(theSwitch.on) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    } else {
        [[UserSettings sharedUserSettings] setApnsToken:nil];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (void)showDirectedPostsSwitchChanged:(UISwitch *)theSwitch
{
    [[UserSettings sharedUserSettings] setShowDirectedPostsInUserStream:theSwitch.on];
}

- (void)showUnifiedStreamSwitchChanged:(UISwitch *)theSwitch
{
    [[UserSettings sharedUserSettings] setShowUnifiedStream:theSwitch.on];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign Out"]) {
        [[APIAuthorization sharedAPIAuthorization] removeProfile:[APIAuthorization sharedAPIAuthorization].currentProfile];
        [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:nil];
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for(NSHTTPCookie *cookie in [cookieStorage cookies]) {
            [cookieStorage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == kSectionAppNet) {
        return @"App.net";
    } else if(section == kSectionNet3000) {
        return @"Zephyr";
    } else if(section == kSectionWebSharing) {
        return @"Web Sharing";
    } else if(section == kSectionPhotoSharing) {
        return @"Photo Sharing";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == kSectionAppNet) {
        return 1;
    } else if(section == kSectionNet3000) {
        return 2;
    } else if(section == kSectionNet3000B) {
        return 5;
    } else if(section == kSectionWebSharing) {
        return 2;
    } else if(section == kSectionPhotoSharing) {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if(indexPath.section == kSectionAppNet) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Accounts";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if(indexPath.section == kSectionNet3000) {
        /*if(indexPath.row == 0) {
            cell.textLabel.text = @"Send Feedback";
        } else */if(indexPath.row == 0) {
            cell.textLabel.text = @"View Welcome Screen";
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"Go to Zephyr Website";
        }
    } else if(indexPath.section == kSectionNet3000B) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Display Name";
            if([[UserSettings sharedUserSettings] showUserName]) {
                cell.detailTextLabel.text = @"Username";
            } else {
                cell.detailTextLabel.text = @"Full Name";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"Refresh Interval";
            if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalManual) {
                cell.detailTextLabel.text = kRefreshIntervalManualString;
            } else if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalFifteenSeconds) {
                cell.detailTextLabel.text = kRefreshIntervalFifteenSecondsString;
            } else if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalThirtySeconds) {
                cell.detailTextLabel.text = kRefreshIntervalThirtySecondsString;
            } else if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalSixtySeconds) {
                cell.detailTextLabel.text = kRefreshIntervalSixtySecondsString;
            } else if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalFiveMinutes) {
                cell.detailTextLabel.text = kRefreshIntervalFiveMinutesString;
            } else if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalFifteenMinutes) {
                cell.detailTextLabel.text = kRefreshIntervalFifteenMinutesString;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 2) {
            cell.textLabel.text = @"Font Size";
            if([[UserSettings sharedUserSettings] bodyFontSize] == kSmallFontSize) {
                cell.detailTextLabel.text = @"Small";
            } else if([[UserSettings sharedUserSettings] bodyFontSize] == kMediumFontSize) {
                cell.detailTextLabel.text = @"Medium";
            } else {
                cell.detailTextLabel.text = @"Large";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*} else if(indexPath.row == 3) {
            cell.textLabel.text = @"Push Notifications";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            [notificationSwitch addTarget:self action:@selector(pushNotificationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [notificationSwitch sizeToFit];
            
            notificationSwitch.on = [[UserSettings sharedUserSettings] apnsToken] != nil;
            cell.accessoryView = notificationSwitch;*/
        } else if(indexPath.row == 3) {
            cell.textLabel.text = @"Show Directed Posts";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            [notificationSwitch addTarget:self action:@selector(showDirectedPostsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [notificationSwitch sizeToFit];
            
            notificationSwitch.on = [[UserSettings sharedUserSettings] showDirectedPostsInUserStream];
            cell.accessoryView = notificationSwitch;
        } else if(indexPath.row == 4) {
            cell.textLabel.text = @"Unified Stream";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UISwitch *notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            [notificationSwitch addTarget:self action:@selector(showUnifiedStreamSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [notificationSwitch sizeToFit];
            
            notificationSwitch.on = [[UserSettings sharedUserSettings] showUnifiedStream];
            cell.accessoryView = notificationSwitch;
        }
    } else if(indexPath.section == kSectionWebSharing) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Instapaper";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"Pocket";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if(indexPath.section == kSectionPhotoSharing) {
        PhotoServiceSetting photoServiceSetting = [[UserSettings sharedUserSettings] photoService];
        
        if(indexPath.row == 0) {
            cell.textLabel.text = @"yfrog";
            if(photoServiceSetting == PhotoServiceSettingYfrog) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"CloudApp";
            if(photoServiceSetting == PhotoServiceSettingCloudApp) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    
    [cell applyDarkGroupedStyle];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [tableView computeHeightForHeaderViewForSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.tableView buildHeaderViewForSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == kSectionAppNet) {
        if(indexPath.row == 0) {
            /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Really Sign Out?" message:@"Do you want to sign out of App.net?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Out", nil];
            [alertView show];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];*/
            AccountsSettingsViewController *controller = [[AccountsSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if(indexPath.section == kSectionNet3000) {
        //if(indexPath.row == 0) {
            /*FeedbackViewController *controller = [[FeedbackViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];*/
            
          //  MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
           // controller.mailComposeDelegate = self;
            //[controller setSubject:@"Zephyr Feedback"];
            //[controller setToRecipients:[NSArray arrayWithObject:@"feedback@enderlabs.com"]];
            //[self presentModalViewController:controller animated:YES];
        /*} else */if(indexPath.row == 0) {
            WelcomeViewController *controller = [[WelcomeViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentModalViewController:navigationController animated:YES];
        } else if(indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://getzephyrapp.com"]];
        }
    } else if(indexPath.section == kSectionNet3000B) {
        if(indexPath.row == 0) {
            NameDisplaySettingsViewController *controller = [[NameDisplaySettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if(indexPath.row == 1) {
            RefreshIntervalSettingsViewController *controller = [[RefreshIntervalSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if(indexPath.row == 2) {
            FontSizeSettingsViewController *controller = [[FontSizeSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if(indexPath.section == kSectionWebSharing) {
        if(indexPath.row == 0) {
            InstapaperSettingsViewController *controller = [[InstapaperSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else if(indexPath.row == 1) {
            PocketSettingsViewController *controller = [[PocketSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if(indexPath.section == kSectionPhotoSharing) {
        if(indexPath.row == 0) {
            [[UserSettings sharedUserSettings] setPhotoService:PhotoServiceSettingYfrog];
            [self.tableView reloadData];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
        } else if(indexPath.row == 1) {
            [[UserSettings sharedUserSettings] setPhotoService:PhotoServiceSettingCloudApp];
            [self.tableView reloadData];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            CloudAppSettingsViewController *controller = [[CloudAppSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark -
#pragma mark MFMailComposeControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
