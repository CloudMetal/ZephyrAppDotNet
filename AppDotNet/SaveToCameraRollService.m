//
//  SaveToCameraRollService.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "SaveToCameraRollService.h"

@implementation SaveToCameraRollService
- (NSString *)title
{
    return @"Save to Camera Roll";
}

- (void)runWithImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)theError contextInfo:(void *)contextInfo
{
    [self serviceDidFinish];
}
@end
