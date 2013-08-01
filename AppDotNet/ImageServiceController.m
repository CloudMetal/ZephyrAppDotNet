//
//  ImageServiceController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ImageServiceController.h"
#import "ImageShareSession.h"

#import "MailImageService.h"
#import "SaveToCameraRollService.h"
#import "CopyImageService.h"

@interface ImageServiceController()
@property (nonatomic, strong) NSMutableArray *sessions;
@end

@implementation ImageServiceController
+ (ImageServiceController *)sharedImageServiceController
{
    static ImageServiceController *sharedImageServiceControllerInstance = nil;
    if(sharedImageServiceControllerInstance == nil) {
        sharedImageServiceControllerInstance = [[ImageServiceController alloc] init];
    }
    return sharedImageServiceControllerInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.sessions = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageShareSessionDidFinish:) name:ImageShareSessionDidFinishNotification object:nil];
    }
    return self;
}

- (void)shareImage:(UIImage *)image inViewController:(UIViewController *)theViewController
{
    if([UIActivityViewController class]) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        [theViewController presentModalViewController:activityViewController animated:YES];
    } else {
        ImageShareSession *session = [[ImageShareSession alloc] init];
        
        session.image = image;
        session.services = @[
            [[MailImageService alloc] initWithParentViewController:theViewController],
            [[SaveToCameraRollService alloc] init],
            [[CopyImageService alloc] init]
        ];
        
        [self.sessions addObject:session];
        
        [session runInViewController:theViewController];
    }
}

- (void)imageShareSessionDidFinish:(NSNotification *)notification
{
    if([self.sessions containsObject:notification.object]) {
        [self.sessions removeObject:notification.object];
    }
}
@end
