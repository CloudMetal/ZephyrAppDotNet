//
//  UserListViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserListViewController.h"
#import "UserListDataController.h"
#import "UserTableViewCell.h"
#import "UserViewController.h"
#import "User.h"
#import "LoadMoreView.h"

@interface UserListViewController() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LoadMoreView *loadMoreView;

@property (nonatomic, strong) UserListDataController *dataController;
@end

@implementation UserListViewController
- (id)init
{
    self = [super initWithNibName:@"UserListViewController" bundle:nil];
    if(self) {
        [self addObserver:self forKeyPath:@"dataController.data.users" options:0 context:0];
        [self addObserver:self forKeyPath:@"dataController.data.hasMore" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"dataController.data.users"];
    [self removeObserver:self forKeyPath:@"dataController.data.hasMore"];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(!self.dataController) {
        self.dataController = [[UserListDataController alloc] init];
        self.dataController.apiCallMaker = self.configuration.apiCallMaker;
        [self.dataController reloadList];
    }
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"dataController.data.users"]) {
        [self.tableView reloadData];
    } else if([keyPath isEqualToString:@"dataController.data.hasMore"]) {
        if(!self.loadMoreView) {
            self.loadMoreView = [[LoadMoreView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
        }
        
        if(self.dataController.data.hasMore) {
            self.tableView.tableFooterView = self.loadMoreView;
        } else {
            self.tableView.tableFooterView = nil;
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataController.data.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.dataController.data.users objectAtIndex:indexPath.row];
    
    UserTableViewCell *cell = [[UserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.user = user;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.dataController.data.users objectAtIndex:indexPath.row];
    
    UserViewController *controller = [[UserViewController alloc] init];
    controller.userID = user.userID;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.dataController.data.hasMore) {
        if(scrollView.contentOffset.y + scrollView.bounds.size.height > (self.loadMoreView.frame.origin.y - 40)) {
            [self.dataController loadMore];
        }
    }
}
@end
