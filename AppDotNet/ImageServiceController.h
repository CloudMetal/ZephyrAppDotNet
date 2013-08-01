//
//  ImageServiceController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface ImageServiceController : NSObject
+ (ImageServiceController *)sharedImageServiceController;

- (void)shareImage:(UIImage *)image inViewController:(UIViewController *)theViewController;
@end
