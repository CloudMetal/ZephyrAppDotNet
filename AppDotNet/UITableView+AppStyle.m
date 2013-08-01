//
//  UITableView+AppStyle.m
//  AppDotNet
//
// Copyright 2012-2013 Ender Labs. All rights reserved.
// Created by Donald Hays.
//

#import "UITableView+AppStyle.h"

@implementation UITableView (AppStyle)
- (UIFont *)headerViewFont
{
    return [UIFont boldSystemFontOfSize:15];
}

- (CGFloat)computeHeightForHeaderViewForSection:(NSInteger)section
{
    NSString *title = [self.dataSource tableView:self titleForHeaderInSection:section];
    if(title.length == 0) {
        return 0;
    }
    
    CGSize size = [title sizeWithFont:[self headerViewFont] constrainedToSize:CGSizeMake(self.bounds.size.width - 20, 1024) lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height + 10;
}

- (UIView *)buildHeaderViewForSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 20, [self.delegate tableView:self heightForHeaderInSection:section])];
    label.text = [self.dataSource tableView:self titleForHeaderInSection:section];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:129.0 / 255.0 green:181.0 / 255.0 blue:212.0 / 255.0 alpha:1.0];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [self headerViewFont];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    return label;
}

- (void)applyDarkGroupedStyle
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.backgroundColor = [UIColor blackColor];
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile-background.png"]];
        backgroundView.image = [backgroundView.image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        self.backgroundView = backgroundView;
    } else {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
        backgroundView.opaque = NO;
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
        
        CGFloat width = 704;
        CGFloat left = roundf((self.superview.bounds.size.width - width) * 0.5);
        self.frame = CGRectMake(left, 0, width, self.superview.bounds.size.height);
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    }
    
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = [UIColor colorWithWhite:0.05 alpha:1.0];
}
@end
