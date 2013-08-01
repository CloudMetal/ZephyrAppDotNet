//
//  ImageService.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

extern NSString *ImageServiceDidFinishNotification;

@interface ImageService : NSObject
- (BOOL)canPerformActivity;
- (NSString *)title;
- (void)runWithImage:(UIImage *)image;
- (void)serviceDidFinish;
@end
