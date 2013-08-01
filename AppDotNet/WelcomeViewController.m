//
//  WelcomeViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController() <UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *panels;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIToolbar *constructedToolbar;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *previousButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextButton;

- (NSInteger)currentPage;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;
@end

@implementation WelcomeViewController
+ (BOOL)shouldShowWelcomeView
{
    NSUInteger viewedVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"ViewedWelcomeViewVersion"];
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"WelcomeViewVersion"] integerValue] > viewedVersion;
}

- (id)init
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"PadWelcomeViewController" bundle:nil];
    } else {
        self = [super initWithNibName:@"WelcomeViewController" bundle:nil];
    }
    if(self) {
        self.title = @"Welcome";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    }
    return self;
}

- (void)viewDidLoad
{
    self.backgroundImageView.image = [self.backgroundImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    
    self.toolbarItems = self.constructedToolbar.items;
    self.pageControl.numberOfPages = self.panels.count;
    self.pageControl.currentPage = 0;
    
    self.scrollView.contentSize = CGSizeMake(0, self.scrollView.bounds.size.height);
    
    self.previousButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView flashScrollIndicators];
    });
}

- (void)viewDidLayoutSubviews
{
    CGFloat left = 0;
    for(UIView *panel in self.panels) {
        CGFloat panelLeft = roundf((self.view.bounds.size.width - panel.bounds.size.width) * 0.5);
        CGFloat panelTop = roundf((self.view.bounds.size.height - panel.bounds.size.height) * 0.5);
        
        panel.frame = CGRectMake(left + panelLeft, panelTop, panel.bounds.size.width, panel.bounds.size.height);
        [self.scrollView addSubview:panel];
        left += self.scrollView.bounds.size.width;
    }
    
    self.scrollView.contentSize = CGSizeMake(left, self.scrollView.bounds.size.height);
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark Private API
- (NSInteger)currentPage
{
    NSInteger page = roundf(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
    page = MIN(page, self.panels.count - 1);
    page = MAX(page, 0);
    
    return page;
}

#pragma mark -
#pragma mark Actions
- (void)done:(id)sender
{
    NSUInteger currentWelcomeViewVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"WelcomeViewVersion"] integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:currentWelcomeViewVersion forKey:@"ViewedWelcomeViewVersion"];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)previous:(id)sender
{
    NSInteger page = self.currentPage;
    if(page > 0) {
        [self.scrollView scrollRectToVisible:CGRectMake((page - 1) * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height) animated:YES];
    }
}

- (IBAction)next:(id)sender
{
    NSInteger page = self.currentPage;
    if(page < self.panels.count - 1) {
        [self.scrollView scrollRectToVisible:CGRectMake((page + 1) * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height) animated:YES];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = [self currentPage];
    
    self.pageControl.currentPage = page;
    self.previousButton.enabled = page > 0;
    self.nextButton.enabled = page < self.panels.count - 1;
}
@end
