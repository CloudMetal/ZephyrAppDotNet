//
//  WebBrowserViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "WebBrowserViewController.h"
#import "NetworkActivityController.h"
#import "URLMenu.h"

@interface WebBrowserViewController() <UIWebViewDelegate>
@property (nonatomic) NSUInteger loadRequestCount;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIToolbar *reloadToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar *stopToolbar;

@property (nonatomic, copy) NSURL *url;

- (void)reloadToolbarContents;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)action:(id)sender;
@end

@implementation WebBrowserViewController
- (id)init
{
    self = [super initWithNibName:@"WebBrowserViewController" bundle:nil];
    if(self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationController.toolbarHidden = NO;
    
    [self reloadToolbarContents];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.webView.delegate = self;
    self.loadRequestCount = 0;
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self reloadToolbarContents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.webView.delegate = nil;
    self.loadRequestCount = 0;
    [[NetworkActivityController sharedNetworkActivityController] endWebViewActivity];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark -
#pragma mark Actions
- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
}

- (IBAction)stop:(id)sender
{
    [self.webView stopLoading];
}

- (IBAction)reload:(id)sender
{
    [self.webView reload];
}

- (IBAction)action:(id)sender
{
    [URLMenu showMenuForURL:self.url title:[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"] viewController:self fromToolbar:self.navigationController.toolbar];
}

#pragma mark -
#pragma mark Public API
- (void)openURL:(NSURL *)theURL
{
    self.url = theURL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:theURL]];
}

#pragma mark -
#pragma mark Private API
- (void)reloadToolbarContents
{
    if(self.loadRequestCount > 0) {
        self.toolbarItems = self.stopToolbar.items;
    } else {
        self.toolbarItems = self.reloadToolbar.items;
    }
    
    UIBarItem *backItem = [self.toolbarItems objectAtIndex:0];
    backItem.enabled = self.webView.canGoBack;
    
    UIBarItem *forwardItem = [self.toolbarItems objectAtIndex:2];
    forwardItem.enabled = self.webView.canGoForward;
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(webView.request.URL) {
        if(![self.url isEqual:self.webView.request.URL]) {
            if(self.webView.request.URL.absoluteString.length > 0) {
                self.url = self.webView.request.URL;
            }
        }
    }
    
    self.loadRequestCount++;
    
    [[NetworkActivityController sharedNetworkActivityController] beginWebViewActivity];
    
    if(self.loadRequestCount == 1) {
        self.title = @"";
    }
    
    [self reloadToolbarContents];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.loadRequestCount > 0) {
        self.loadRequestCount--;
    }
    
    [[NetworkActivityController sharedNetworkActivityController] endWebViewActivity];
    
    if(self.loadRequestCount == 0) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    [self reloadToolbarContents];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self webViewDidFinishLoad:webView];
}
@end
