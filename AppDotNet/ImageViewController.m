//
//  ImageViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ImageViewController.h"
#import "VDownload.h"
#import "ImageServiceController.h"

@interface ImageViewController() <VDownloadDelegate>
@property (nonatomic, strong) VDownload *download;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (NSURL *)buildDownloadURL;
- (void)downloadImage;
@end

@implementation ImageViewController

+ (BOOL)canHandleURL:(NSURL *)theURL
{
    NSString *asString = [theURL absoluteString];
    
    asString = [asString lowercaseString];
    
    NSArray *extensions = @[@"tiff", @"tif", @"jpg", @"jpeg", @"png", @"bmp"];
    
    if([asString rangeOfString:@"http://yfrog.com/"].location == 0) {
        return YES;
    } else if([extensions containsObject:[asString pathExtension]]) {
        return YES;
    }
    
    return NO;
}

- (id)init
{
    self = [super initWithNibName:@"ImageViewController" bundle:nil];
    if(self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
        
        [self addObserver:self forKeyPath:@"url" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    self.download.delegate = nil;
    [self.download cancel];
    self.download = nil;
    
    [self removeObserver:self forKeyPath:@"url"];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self downloadImage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"url"]) {
        [self downloadImage];
    }
}

#pragma mark -
#pragma mark Private API
- (NSURL *)buildDownloadURL
{
    if([self.url.absoluteString rangeOfString:@"http://yfrog.com/"].location == 0) {
        return [NSURL URLWithString:[self.url.absoluteString stringByAppendingString:@":iphone"]];
    }
    
    return self.url;
}

- (void)downloadImage
{
    if(self.download != nil || self.imageView.image != nil) {
        return;
    }
    
    if(self.url == nil) {
        return;
    }
    
    self.download = [[VDownload alloc] init];
    self.download.delegate = self;
    self.download.method = VDownloadMethodGET;
    self.download.url = [self buildDownloadURL];
    [self.download start];
}

#pragma mark -
#pragma mark Actions

- (void)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)action:(id)sender
{
    if(!self.imageView.image) {
        return;
    }
    
    [[ImageServiceController sharedImageServiceController] shareImage:self.imageView.image inViewController:self];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    UIImage *image = [[UIImage alloc] initWithData:theData];
    self.imageView.image = image;
    
    self.download = nil;
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    
}
@end
