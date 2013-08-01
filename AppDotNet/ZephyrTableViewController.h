//
//  ZephyrTableViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface ZephyrTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readonly, strong) UITableView *tableView;

- (id)initWithStyle:(UITableViewStyle)theStyle;
@end
