//
//  DraftsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "DraftsViewController.h"
#import "Drafts.h"

@implementation DraftsViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        }
        
        self.title = @"Drafts";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView applyDarkGroupedStyle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Draft *draft = [[[Drafts sharedDrafts] drafts] objectAtIndex:indexPath.row];
    
    return MAX([draft.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width - 40, 1024) lineBreakMode:UILineBreakModeWordWrap].height + 20, 44);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Drafts sharedDrafts] drafts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    Draft *draft = [[[Drafts sharedDrafts] drafts] objectAtIndex:indexPath.row];
    
    //tableViewCell.backgroundColor = [UIColor postBackgroundColor];
    tableViewCell.textLabel.font = [UIFont systemFontOfSize:15];
    //tableViewCell.textLabel.textColor = [UIColor postBodyTextColor];
    tableViewCell.textLabel.text = draft.text;
    tableViewCell.textLabel.numberOfLines = 0;
    
    [tableViewCell applyDarkGroupedStyle];
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.pickedDraftAction) {
        self.pickedDraftAction([[[Drafts sharedDrafts] drafts] objectAtIndex:indexPath.row]);
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
