//
//  TabBarViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface TabBarViewController : UIViewController
@property (nonatomic, strong) IBOutletCollection(UIViewController) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *selectedViewController;
@end
