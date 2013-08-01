//
//  ImageShareSession.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

extern NSString *ImageShareSessionDidFinishNotification;

@interface ImageShareSession : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSArray *services;

- (void)runInViewController:(UIViewController *)theViewController;
@end
