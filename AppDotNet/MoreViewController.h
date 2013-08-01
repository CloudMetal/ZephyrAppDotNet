//
//  MoreViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface MoreViewController : UITableViewController
@property (nonatomic, strong) NSArray *viewControllers;

- (void)pushLastViewController;
@end
