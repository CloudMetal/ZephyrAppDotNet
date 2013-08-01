//
//  AccountSettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AccountSettingsViewController.h"
#import "APIAuthorization.h"
#import "PushNotificationManager.h"

@interface AccountSettingsViewController() <UIAlertViewDelegate>
@end

@implementation AccountSettingsViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        [self addObserver:self forKeyPath:@"profile" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"profile"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"profile"]) {
        self.title = self.profile.user;
        
        [self.tableView reloadData];
    }
}

- (void)pushSwitchChanged:(UISwitch *)sender
{
    if([sender isOn]) {
        [[PushNotificationManager sharedPushNotificationManager] registerProfileForPushNotifications:self.profile];
    } else {
        [[PushNotificationManager sharedPushNotificationManager] unregisterProfileForPushNotifications:self.profile];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove"]) {
        [[APIAuthorization sharedAPIAuthorization] removeProfile:self.profile];
        if([[APIAuthorization sharedAPIAuthorization] currentProfile] == self.profile) {
            if([[[APIAuthorization sharedAPIAuthorization] profiles] count] > 0) {
                [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:[[[APIAuthorization sharedAPIAuthorization] profiles] objectAtIndex:0]];
            } else {
                [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:nil];
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if(indexPath.section == 0) {
        cell.textLabel.text = @"Push Notifications";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *pushSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [pushSwitch addTarget:self action:@selector(pushSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [pushSwitch sizeToFit];
        
        pushSwitch.on = self.profile.authorizedForPushNotifications;
        cell.accessoryView = pushSwitch;
    } else if(indexPath.section == 1) {
        cell.textLabel.text = @"Remove Account";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    [cell applyDarkGroupedStyle];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if(indexPath.section == 0) {
        
    } else if(indexPath.section == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Account?" message:@"Are you sure you wish to remove this account from Zephyr?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
        [alertView show];
    }
}
@end
