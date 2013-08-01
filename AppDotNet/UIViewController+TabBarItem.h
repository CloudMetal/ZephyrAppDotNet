//
//  UIViewController+TabBarItem.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <UIKit/UIKit.h>
#import "TabBarItem.h"

@interface UIViewController (TabBarItem)
@property (nonatomic, readonly) TabBarItem *adnTabBarItem;
@end
