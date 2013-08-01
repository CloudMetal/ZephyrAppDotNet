//
//  ImageViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface ImageViewController : UIViewController
+ (BOOL)canHandleURL:(NSURL *)theURL;

@property (nonatomic, copy) NSURL *url;
@end
