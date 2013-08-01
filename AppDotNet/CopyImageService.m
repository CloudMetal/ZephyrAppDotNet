//
//  CopyImageService.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "CopyImageService.h"

@implementation CopyImageService
- (NSString *)title
{
    return @"Copy Image";
}

- (void)runWithImage:(UIImage *)image
{
    [[UIPasteboard generalPasteboard] setImage:image];
    [self serviceDidFinish];
}
@end
