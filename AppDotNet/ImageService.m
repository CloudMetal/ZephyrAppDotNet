//
//  ImageService.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ImageService.h"

NSString *ImageServiceDidFinishNotification = @"ImageServiceDidFinishNotification";

@implementation ImageService
- (BOOL)canPerformActivity
{
    return YES;
}

- (NSString *)title
{
    return @"Service";
}

- (void)runWithImage:(UIImage *)image
{
    [self serviceDidFinish];
}

- (void)serviceDidFinish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ImageServiceDidFinishNotification object:self];
}
@end
