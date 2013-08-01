//
//  ExpiredViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ExpiredViewController.h"

@interface ExpiredViewController()
- (IBAction)gotoWebsite:(id)sender;
@end

@implementation ExpiredViewController
- (id)init
{
    self = [super initWithNibName:@"ExpiredViewController" bundle:nil];
    if(self) {
        
    }
    return self;
}

- (IBAction)gotoWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://getzephyrapp.com"]];
}
@end
