//
//  FontSizeSettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "FontSizeSettingsViewController.h"
#import "UserSettings.h"

@implementation FontSizeSettingsViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.title = @"Font Size";
    }
    return self;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Small";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kSmallFontSize];
        
        if([[UserSettings sharedUserSettings] bodyFontSize] == kSmallFontSize) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"Medium";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kMediumFontSize];
        
        if([[UserSettings sharedUserSettings] bodyFontSize] == kMediumFontSize) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 2) {
        cell.textLabel.text = @"Large";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kLargeFontSize];
        
        if([[UserSettings sharedUserSettings] bodyFontSize] == kLargeFontSize) {
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
        [[UserSettings sharedUserSettings] setBodyFontSize:kSmallFontSize];
    } else if(indexPath.row == 1) {
        [[UserSettings sharedUserSettings] setBodyFontSize:kMediumFontSize];
    } else if(indexPath.row == 2) {
        [[UserSettings sharedUserSettings] setBodyFontSize:kLargeFontSize];
    }
    
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
}
@end
