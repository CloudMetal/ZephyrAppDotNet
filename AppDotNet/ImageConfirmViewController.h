//
//  ImageConfirmViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@class ImageConfirmViewController;

@protocol ImageConfirmViewControllerDelegate <NSObject>
- (void)imageConfirmViewController:(ImageConfirmViewController *)theController confirmedImage:(UIImage *)image;
- (void)imageConfirmViewControllerCancelled:(ImageConfirmViewController *)theController;
@end

@interface ImageConfirmViewController : UIViewController
@property (nonatomic, weak) IBOutlet id<ImageConfirmViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *image;
@end
