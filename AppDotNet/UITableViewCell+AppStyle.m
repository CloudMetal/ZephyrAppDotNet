//
//  UITableViewCell+AppStyle.m
//  AppDotNet
//
// Copyright 2012-2013 Ender Labs. All rights reserved.
// Created by Donald Hays.
//

#import "UITableViewCell+AppStyle.h"

@implementation UITableViewCell (AppStyle)
- (UIImageView *)makeChevronView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron-white.png"]];
    imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
    return imageView;
}

- (UIImageView *)makeCheckView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-white.png"]];
    imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
    return imageView;
}

- (void)applyDarkGroupedStyle
{
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    
    self.textLabel.textColor = [UIColor colorWithWhite:0.81 alpha:1];
    self.textLabel.shadowColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.textLabel.shadowOffset = CGSizeMake(0, 1);
    
    self.detailTextLabel.textColor = [UIColor colorWithRed:0.6 green:0.8 blue:0.95 alpha:1.0];
    self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
    
    if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        self.accessoryView = [self makeChevronView];
    }
    
    if(self.accessoryType == UITableViewCellAccessoryCheckmark) {
        self.accessoryView = [self makeCheckView];
    }
}
@end
