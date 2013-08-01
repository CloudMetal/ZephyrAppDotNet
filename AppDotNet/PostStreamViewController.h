//
//  PostStreamViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "PostStreamConfiguration.h"

@interface PostStreamViewController : UIViewController
@property (nonatomic, strong) IBOutlet PostStreamConfiguration *postStreamConfiguration;

@property (nonatomic, copy) NSString *focusedPostID;
@end
