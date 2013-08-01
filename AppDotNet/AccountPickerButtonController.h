//
//  AccountPickerButtonController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface AccountPickerButtonController : NSObject
+ (AccountPickerButtonController *)sharedAccountPickerButtonController;

- (void)addViewController:(UIViewController *)theViewController;
@end
