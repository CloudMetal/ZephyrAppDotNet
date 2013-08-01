//
//  NameDisplaySettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "NameDisplaySettingsViewController.h"
#import "UserSettings.h"

@interface NameDisplaySettingsViewController ()

@end

@implementation NameDisplaySettingsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.title = @"Display Name";
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"The name format affects how names are shown to you in posts.";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [tableView computeHeightForHeaderViewForSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.tableView buildHeaderViewForSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Full Name";
        
        if(![[UserSettings sharedUserSettings] showUserName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"Username";
        
        if([[UserSettings sharedUserSettings] showUserName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    [cell applyDarkGroupedStyle];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        [[UserSettings sharedUserSettings] setShowUserName:NO];
    } else {
        [[UserSettings sharedUserSettings] setShowUserName:YES];
    }
    
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
