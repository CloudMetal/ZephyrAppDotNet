//
//  AuthorizationViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AuthorizationViewController.h"
#import "APIAuthorization.h"

@interface AuthorizationViewController() <UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView *webView;

- (IBAction)cancel:(id)sender;
@end

@implementation AuthorizationViewController
- (id)init
{
    self = [super initWithNibName:@"AuthorizationViewController" bundle:nil];
    if(self) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            if([cookie.domain rangeOfString:@"app.net"].location != NSNotFound) {
                [storage deleteCookie:cookie];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(KeyADNClientID) {
        NSString *urlString = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri=https://getzephyrapp.com/callback&scope=stream,write_post,follow,messages&adnview=appstore", KeyADNClientID];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    } else {
        [self.webView loadHTMLString:@"<p><b>Didn't read the README, did you?</b></p><p>You must provide an App.net Client ID in Keys.h before Zephyr can go to the App.net authorization page.</p>" baseURL:nil];
    }
}

#pragma mark -
#pragma mark Actions
- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if([[url host] isEqualToString:@"getzephyrapp.com"]) {
        NSString *token = [[url fragment] substringFromIndex:[[url fragment] rangeOfString:@"="].location + 1];
        [[APIAuthorization sharedAPIAuthorization] addProfileWithAccessToken:token];
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}
@end
