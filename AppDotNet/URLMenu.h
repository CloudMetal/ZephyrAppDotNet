//
//  URLMenu.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface URLMenu : NSObject
+ (void)showMenuForURL:(NSURL *)theURL title:(NSString *)theTitle viewController:(UIViewController *)theViewController fromToolbar:(UIToolbar *)theToolbar;
+ (void)showMenuForURL:(NSURL *)theURL title:(NSString *)theTitle viewController:(UIViewController *)theViewController inView:(UIView *)theView;
@end
