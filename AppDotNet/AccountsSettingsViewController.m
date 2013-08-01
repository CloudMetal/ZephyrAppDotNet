//
//  AccountsSettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AccountsSettingsViewController.h"
#import "APIAuthorization.h"
#import "AuthorizationViewController.h"
#import "AccountSettingsViewController.h"

#define AccountListSection 0
#define AccountOptionsSection 1

#define AccountOptionAddIndex 0

@implementation AccountsSettingsViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.title = @"Accounts";
        
        [[APIAuthorization sharedAPIAuthorization] addObserver:self forKeyPath:@"profiles" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [[APIAuthorization sharedAPIAuthorization] removeObserver:self forKeyPath:@"profiles"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"profiles"]) {
        [self.tableView reloadData];
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
    if(section == AccountListSection) {
        return [[[APIAuthorization sharedAPIAuthorization] profiles] count];
    } else if(section == AccountOptionsSection) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if(indexPath.section == AccountListSection) {
        APIAuthorizationProfile *profile = [[[APIAuthorization sharedAPIAuthorization] profiles] objectAtIndex:indexPath.row];
        cell.textLabel.text = profile.user;
        
        UIRectCorner corners = 0;
        if(indexPath.row == 0) {
            corners |= UIRectCornerTopLeft;
        }
        
        if(indexPath.row == ([[[APIAuthorization sharedAPIAuthorization] profiles] count] - 1)) {
            corners |= UIRectCornerBottomLeft;
        }
        
        UIImage *image = [[APIAuthorization sharedAPIAuthorization] imageForProfile:profile];
        image = [image fittedImageInSize:CGSizeMake(44, 44)];
        image = [image roundedImageByRoundingCorners:corners cornerRadii:CGSizeMake(6.5, 6.5)];
        
        cell.imageView.image = image;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if(indexPath.section == AccountOptionsSection) {
        if(indexPath.row == AccountOptionAddIndex) {
            cell.textLabel.text = @"Add Account";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
    }
    
    [cell applyDarkGroupedStyle];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        APIAuthorizationProfile *profile = [[[APIAuthorization sharedAPIAuthorization] profiles] objectAtIndex:indexPath.row];
        [[APIAuthorization sharedAPIAuthorization] removeProfile:profile];
        if(profile == [[APIAuthorization sharedAPIAuthorization] currentProfile]) {
            [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:nil];
        }
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == AccountListSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == AccountListSection) {
        APIAuthorizationProfile *profile = [[[APIAuthorization sharedAPIAuthorization] profiles] objectAtIndex:indexPath.row];
        AccountSettingsViewController *controller = [[AccountSettingsViewController alloc] init];
        controller.profile = profile;
        
        [self.navigationController pushViewController:controller animated:YES];
    } else if(indexPath.section == AccountOptionsSection) {
        if(indexPath.row == AccountOptionAddIndex) {
            AuthorizationViewController *controller = [[AuthorizationViewController alloc] init];
            [self presentModalViewController:controller animated:YES];
        }
    }
}
@end
