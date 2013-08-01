//
//  SearchViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "SearchViewController.h"
#import "HashtagPostStreamConfiguration.h"
#import "UserMentionStreamConfiguration.h"
#import "PostStreamViewController.h"
#import "UserViewController.h"
#import "UserListViewController.h"
#import "UserSearchConfiguration.h"
#import "RecentSearches.h"
#import "PadContentView.h"

@interface SearchViewController() <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL showingQueryRows;

- (NSString *)query;

- (void)resizeTableViewAgainstKeyboardDictionary:(NSDictionary *)dictionary;
- (CGFloat)topOfView:(UIView *)view;
- (NSUInteger)numberOfRowsForSearchQuery;
@end

@implementation SearchViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.tableView.visibleCells.count > 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)viewDidLoad
{
    [self.tableView applyDarkGroupedStyle];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PadContentView *padContentView = [[PadContentView alloc] initWithFrame:self.view.bounds];
        padContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:padContentView atIndex:0];
        
        padContentView.passThroughViewTarget = self.tableView;
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.searchBar.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.searchBar.frame.size.height);
    }
}

#pragma mark -
#pragma mark Notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self resizeTableViewAgainstKeyboardDictionary:notification.userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self resizeTableViewAgainstKeyboardDictionary:notification.userInfo];
}

#pragma mark -
#pragma mark Private API
- (void)resizeTableViewAgainstKeyboardDictionary:(NSDictionary *)dictionary
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
    CGFloat tableViewTop = [self topOfView:self.tableView];
    
    CGFloat keyboardTop = [[dictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat tableViewHeightFromKeyboardTop = keyboardTop - tableViewTop;
    CGFloat tableViewHeightFromContainerFrame = self.tableView.superview.bounds.size.height - tableViewTop;
    
    CGFloat destinationHeight = MIN(tableViewHeightFromContainerFrame, tableViewHeightFromKeyboardTop);
    
    if(keyboardTop == [[UIScreen mainScreen] bounds].size.height) {
        destinationHeight = self.tableView.superview.bounds.size.height - self.tableView.frame.origin.y;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if(tableViewHeightFromKeyboardTop < tableViewHeightFromContainerFrame) {
        [UIView setAnimationDelay:0.1];
    }
    [UIView setAnimationDuration:[[dictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[dictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      self.tableView.bounds.size.width,
                                      destinationHeight);
    [UIView commitAnimations];
}

- (CGFloat)topOfView:(UIView *)view
{
    if(!view.superview) {
        return view.frame.origin.y;
    } else {
        return view.frame.origin.y + [self topOfView:view.superview];
    }
}

- (NSString *)query
{
    return [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSUInteger)numberOfRowsForSearchQuery
{
    NSString *query = self.query;
    if(query.length == 0) {
        return 0;
    }
    
    if([query rangeOfString:@"@"].location == 0) {
        if(query.length > 1) {
            return 2;
        } else {
            return 0;
        }
    } else if([query rangeOfString:@"#"].location == 0) {
        if(query.length > 1) {
            return 1;
        } else {
            return 0;
        }
    }
    
    return 4;
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if((self.showingQueryRows && self.query.length == 0) || (!self.showingQueryRows && self.query.length != 0)) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if(self.query.length > 0) {
        self.showingQueryRows = YES;
    } else {
        self.showingQueryRows = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    return;
    
    searchBar.text = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [searchBar resignFirstResponder];
    
    PostStreamConfiguration *configuration = nil;
    PostStreamViewController *controller = [[PostStreamViewController alloc] init];
    
    if(searchBar.selectedScopeButtonIndex == 0) {
        HashtagPostStreamConfiguration *hashtagConfiguration = [[HashtagPostStreamConfiguration alloc] init];
        hashtagConfiguration.hashtag = searchBar.text;
        controller.title = [NSString stringWithFormat:@"#%@", searchBar.text];
        
        configuration = hashtagConfiguration;
    } else if(searchBar.selectedScopeButtonIndex == 1) {
        UserMentionStreamConfiguration *userMentionConfiguration = [[UserMentionStreamConfiguration alloc] init];
        userMentionConfiguration.userID = [NSString stringWithFormat:@"@%@", searchBar.text];
        controller.title = userMentionConfiguration.userID;
        
        configuration = userMentionConfiguration;
    }
    
    controller.postStreamConfiguration = configuration;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([[RecentSearches sharedRecentSearches] recentHashtags].count > 0) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return [self numberOfRowsForSearchQuery];
    } else if(section == 1) {
        return [[[RecentSearches sharedRecentSearches] recentHashtags] count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1) {
        return @"Recent Hashtags";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [tableView computeHeightForHeaderViewForSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.tableView buildHeaderViewForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            if([self.query rangeOfString:@"@"].location == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Go to User \"%@\"", [self.query substringFromIndex:1]];
            } else if([self.query rangeOfString:@"#"].location == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Search Hashtag \"#%@\"", [self.query substringFromIndex:1]];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Search Users for \"%@\"", self.query];
            }
        } else if(indexPath.row == 1) {
            if([self.query rangeOfString:@"@"].location == 0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Search Mentions \"%@\"", self.query];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Go to User \"%@\"", self.query];
            }
        } else if(indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"Search Mentions \"@%@\"", self.query];
        } else if(indexPath.row == 3) {
            cell.textLabel.text = [NSString stringWithFormat:@"Search Hashtag \"#%@\"", self.query];
        }
    } else if(indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"#%@", [[[RecentSearches sharedRecentSearches] recentHashtags] objectAtIndex:indexPath.row]];
    }
    
    [cell applyDarkGroupedStyle];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        if(editingStyle == UITableViewCellEditingStyleDelete) {
            [self.tableView beginUpdates];
            [[RecentSearches sharedRecentSearches] removeHashtag:[[[RecentSearches sharedRecentSearches] recentHashtags] objectAtIndex:indexPath.row]];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            if([[[RecentSearches sharedRecentSearches] recentHashtags] count] == 0) {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [self.tableView endUpdates];
        }
    }
}

- (void)searchForUser:(NSString *)theUser
{
    UserSearchConfiguration *configuration = [[UserSearchConfiguration alloc] init];
    configuration.query = theUser;
    
    UserListViewController *controller = [[UserListViewController alloc] init];
    controller.title = theUser;
    controller.configuration = configuration;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goToUser:(NSString *)theUser
{
    UserViewController *controller = [[UserViewController alloc] init];
    controller.userID = [NSString stringWithFormat:@"@%@", theUser];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewMentionsOfUser:(NSString *)theUser
{
    PostStreamConfiguration *configuration = nil;
    PostStreamViewController *controller = [[PostStreamViewController alloc] init];
    
    UserMentionStreamConfiguration *userMentionConfiguration = [[UserMentionStreamConfiguration alloc] init];
    userMentionConfiguration.userID = [NSString stringWithFormat:@"@%@", theUser];
    controller.title = userMentionConfiguration.userID;
    
    configuration = userMentionConfiguration;
    controller.postStreamConfiguration = configuration;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)searchHashtag:(NSString *)theHashtag addToList:(BOOL)shouldAddToList
{
    PostStreamConfiguration *configuration = nil;
    PostStreamViewController *controller = [[PostStreamViewController alloc] init];
    
    HashtagPostStreamConfiguration *hashtagConfiguration = [[HashtagPostStreamConfiguration alloc] init];
    hashtagConfiguration.hashtag = theHashtag;
    controller.title = [NSString stringWithFormat:@"#%@", theHashtag];
    
    if(shouldAddToList) {
        BOOL addingFirstHashtag = [[[RecentSearches sharedRecentSearches] recentHashtags] count] == 0;
        
        [[RecentSearches sharedRecentSearches] addHashtag:theHashtag];
        
        if(addingFirstHashtag) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    configuration = hashtagConfiguration;
    controller.postStreamConfiguration = configuration;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            if([self.query rangeOfString:@"@"].location == 0) {
                [self goToUser:[self.query substringFromIndex:1]];
            } else if([self.query rangeOfString:@"#"].location == 0) {
                [self searchHashtag:[self.query substringFromIndex:1] addToList:YES];
            } else {
                [self searchForUser:self.query];
            }
        } else if(indexPath.row == 1) {
            if([self.query rangeOfString:@"@"].location == 0) {
                [self viewMentionsOfUser:[self.query substringFromIndex:1]];
            } else {
                [self goToUser:self.query];
            }
        } else if(indexPath.row == 2) {
            [self viewMentionsOfUser:self.query];
        } else if(indexPath.row == 3) {
            [self searchHashtag:self.query addToList:YES];
        }
    } else if(indexPath.section == 1) {
        [self searchHashtag:[[[RecentSearches sharedRecentSearches] recentHashtags] objectAtIndex:indexPath.row] addToList:NO];
    }
}
@end
