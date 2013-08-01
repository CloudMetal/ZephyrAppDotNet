//
//  ImageConfirmViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ImageConfirmViewController.h"

@interface ImageConfirmViewController()
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

- (IBAction)cancel:(id)sender;
- (IBAction)choose:(id)sender;
@end

@implementation ImageConfirmViewController
- (id)init
{
    self = [super initWithNibName:@"ImageConfirmViewController" bundle:nil];
    if(self) {
        self.title = @"Preview";
        
        [self addObserver:self forKeyPath:@"image" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"image"];
}

- (void)viewDidLoad
{
    self.imageView.image = self.image;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"image"]) {
        self.imageView.image = self.image;
    }
}

#pragma mark -
#pragma mark Actions
- (IBAction)cancel:(id)sender
{
    [self.delegate imageConfirmViewControllerCancelled:self];
}

- (IBAction)choose:(id)sender
{
    [self.delegate imageConfirmViewController:self confirmedImage:self.image];
}
@end
