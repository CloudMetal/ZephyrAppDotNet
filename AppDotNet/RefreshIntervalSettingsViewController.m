//
//  RefreshIntervalSettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "RefreshIntervalSettingsViewController.h"
#import "UserSettings.h"

@implementation RefreshIntervalSettingsViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.title = @"Refresh Interval";
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = kRefreshIntervalManualString;
        if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalManual) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 1) {
        cell.textLabel.text = kRefreshIntervalFifteenSecondsString;
        if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalFifteenSeconds) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 2) {
        cell.textLabel.text = kRefreshIntervalThirtySecondsString;
        if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalThirtySeconds) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 3) {
        cell.textLabel.text = kRefreshIntervalSixtySecondsString;
        if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalSixtySeconds) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 4) {
        cell.textLabel.text = kRefreshIntervalFiveMinutesString;
        if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalFiveMinutes) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 5) {
        cell.textLabel.text = kRefreshIntervalFifteenMinutesString;
        if([[UserSettings sharedUserSettings] refreshInterval] == kRefreshIntervalFifteenMinutes) {
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
        [[UserSettings sharedUserSettings] setRefreshInterval:kRefreshIntervalManual];
    } else if(indexPath.row == 1) {
        [[UserSettings sharedUserSettings] setRefreshInterval:kRefreshIntervalFifteenSeconds];
    } else if(indexPath.row == 2) {
        [[UserSettings sharedUserSettings] setRefreshInterval:kRefreshIntervalThirtySeconds];
    } else if(indexPath.row == 3) {
        [[UserSettings sharedUserSettings] setRefreshInterval:kRefreshIntervalSixtySeconds];
    } else if(indexPath.row == 4) {
        [[UserSettings sharedUserSettings] setRefreshInterval:kRefreshIntervalFiveMinutes];
    } else if(indexPath.row == 5) {
        [[UserSettings sharedUserSettings] setRefreshInterval:kRefreshIntervalFifteenMinutes];
    }
    
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
}
@end
