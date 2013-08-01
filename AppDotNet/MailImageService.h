//
//  MailImageService.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "ImageService.h"

@interface MailImageService : ImageService
- (id)initWithParentViewController:(UIViewController *)theViewController;
@end
