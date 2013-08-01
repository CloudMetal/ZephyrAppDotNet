//
//  AccountSettingsViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "ZephyrTableViewController.h"
#import "APIAuthorizationProfile.h"

@interface AccountSettingsViewController : ZephyrTableViewController
@property (nonatomic, strong) APIAuthorizationProfile *profile;
@end
