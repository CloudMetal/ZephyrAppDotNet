//
//  ImageShareSession.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ImageShareSession.h"
#import "ImageService.h"

NSString *ImageShareSessionDidFinishNotification = @"ImageShareSessionDidFinishNotification";

@interface ImageShareSession() <UIActionSheetDelegate>
@end

@implementation ImageShareSession
- (id)init
{
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageServiceDidFinish:) name:ImageServiceDidFinishNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ImageServiceDidFinishNotification object:nil];
}

- (void)runInViewController:(UIViewController *)theViewController
{
    self.services = [self.services arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
        ImageService *service = theElement;
        return [service canPerformActivity];
    }];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for(ImageService *service in self.services) {
        [actionSheet addButtonWithTitle:service.title];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    
    [actionSheet showInView:theViewController.view];
}

#pragma mark -
#pragma mark Notifications
- (void)imageServiceDidFinish:(NSNotification *)notification
{
    if([self.services containsObject:notification.object]) {
        self.image = nil;
        self.services = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ImageShareSessionDidFinishNotification object:self];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < self.services.count) {
        ImageService *service = [self.services objectAtIndex:buttonIndex];
        
        [service runWithImage:self.image];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ImageShareSessionDidFinishNotification object:self];
    }
}
@end
