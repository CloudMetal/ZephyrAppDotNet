//
//  ZephyrTableViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ZephyrTableViewController.h"
#import "PadContentView.h"

@interface ZephyrTableViewController()
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ZephyrTableViewController
- (id)initWithStyle:(UITableViewStyle)theStyle
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 256, 256) style:theStyle];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
    view.opaque = NO;
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PadContentView *contentView = [[PadContentView alloc] initWithFrame:view.bounds];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:contentView];
    }
    
    self.tableView.frame = view.bounds;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view addSubview:self.tableView];

    [self.tableView applyDarkGroupedStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:-1 inSection:-1] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}
@end
