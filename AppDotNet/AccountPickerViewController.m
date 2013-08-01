//
//  AccountPickerViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AccountPickerViewController.h"
#import "APIAuthorization.h"

@implementation AccountPickerViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        self.title = @"Accounts";
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    return self;
}

#pragma mark -
#pragma mark Actions
- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[APIAuthorization sharedAPIAuthorization] profiles] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    APIAuthorizationProfile *profile = [[[APIAuthorization sharedAPIAuthorization] profiles] objectAtIndex:indexPath.row];
    cell.textLabel.text = profile.user;
    cell.imageView.image = [[APIAuthorization sharedAPIAuthorization] imageForProfile:profile];
    
    if(profile == [[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APIAuthorizationProfile *profile = [[[APIAuthorization sharedAPIAuthorization] profiles] objectAtIndex:indexPath.row];
    [[APIAuthorization sharedAPIAuthorization] setCurrentProfile:profile];
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
