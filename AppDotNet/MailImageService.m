//
//  MailImageService.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "MailImageService.h"
#import <MessageUI/MessageUI.h>

@interface MailImageService() <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIViewController *parentViewController;
@end

@implementation MailImageService
- (id)initWithParentViewController:(UIViewController *)theViewController
{
    self = [super init];
    if(self) {
        self.parentViewController = theViewController;
    }
    return self;
}

- (BOOL)canPerformActivity
{
    return [MFMailComposeViewController canSendMail];
}

- (NSString *)title
{
    return @"Mail Image";
}

- (void)runWithImage:(UIImage *)image
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController addAttachmentData:UIImagePNGRepresentation(image) mimeType:@"image/png" fileName:@"image.png"];
    [self.parentViewController presentModalViewController:mailViewController animated:YES];
}

#pragma mark -
#pragma mark MFMailComposerViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
    [self serviceDidFinish];
}
@end
