//
//  UITableView+AppStyle.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <UIKit/UIKit.h>

@interface UITableView (AppStyle)
- (CGFloat)computeHeightForHeaderViewForSection:(NSInteger)section;
- (UIView *)buildHeaderViewForSection:(NSInteger)section;
- (void)applyDarkGroupedStyle;
@end
