//
//  TabBar.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "TabBarItem.h"

@interface TabBar : UIView
@property (nonatomic, readonly) BOOL showingMore;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) TabBarItem *selectedItem;

- (void)showLess;
@end
