//
//  AppDelegate.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "AuthenticatedUser.h"
#import "ExpiredViewController.h"
#import "UserSettings.h"
#import "PushNotificationManager.h"

@interface AppDelegate()
@property (nonatomic, strong) RootViewController *rootViewController;
@property (nonatomic, strong) NSTimer *autoRefreshTimer;

- (void)themeApp;

- (void)startAutoRefreshTimer;
- (void)stopAutoRefreshTimer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self themeApp];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [self startAutoRefreshTimer];
    [[UserSettings sharedUserSettings] addObserver:self forKeyPath:@"refreshInterval" options:0 context:0];
    
    if(KeyTestFlightTeamToken) {
        [TestFlight takeOff:KeyTestFlightTeamToken];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
#ifdef APP_EXPIRES
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:@"2013-01-12"];
    NSLog(@"This build expires on %@", date);
    
    if([date timeIntervalSinceNow] < 0) {
        ExpiredViewController *controller = [[ExpiredViewController alloc] init];
        self.window.rootViewController = controller;
        
        self.window.backgroundColor = [UIColor blackColor];
        [self.window makeKeyAndVisible];
        return YES;
    }
#endif
    
    [AuthenticatedUser sharedAuthenticatedUser];
    
    self.rootViewController = [[RootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self stopAutoRefreshTimer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self startAutoRefreshTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *string = [deviceToken description];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //[[UserSettings sharedUserSettings] setApnsToken:string];
    //[[UserSettings sharedUserSettings] setApnsTokenRegisteredInSandbox:[[UIApplication sharedApplication] isSandboxed]];
    
    [[PushNotificationManager sharedPushNotificationManager] applicationRegisteredPushToken:string isSandbox:[[UIApplication sharedApplication] isSandboxed]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [[PushNotificationManager sharedPushNotificationManager] applicationFailedToRegisterPushToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSLog(@"Got notification %@", userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:ADNUIApplicationDidReceivePushNotificationNotification object:[UIApplication sharedApplication] userInfo:userInfo];
    //[self.rootViewController showMentionTab];
}

- (void)themeApp
{
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"search-bar-field-bg.png"]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-bar-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-ls-bar-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forBarMetrics:UIBarMetricsLandscapePhone];
    
    [[UIToolbar appearance] setTintColor:[UIColor darkGrayColor]];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"tool-bar-bg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-back-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 14, 4, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-back-button-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 14, 4, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-ls-back-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 14, 4, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-ls-back-button-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 14, 4, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-bar-item.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-bar-item-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-ls-bar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"nav-ls-bar-button-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 4, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    UISwitch *themeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    if([themeSwitch respondsToSelector:@selector(setOnTintColor:)]) {
        [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:0 green:0.15 blue:0.25 alpha:1.0]];
    }
    
    if([themeSwitch respondsToSelector:@selector(setTintColor:)]) {
        [[UISwitch appearance] setTintColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    }
    
    if([themeSwitch respondsToSelector:@selector(setThumbTintColor:)]) {
        [[UISwitch appearance] setThumbTintColor:[UIColor lightGrayColor]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"refreshInterval"]) {
        [self stopAutoRefreshTimer];
        [self startAutoRefreshTimer];
    }
}

- (void)autoRefreshTimerElapsed:(NSTimer *)timer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ADNUIApplicationAutoRefreshIntervalPassedNotification object:[UIApplication sharedApplication]];
}

- (void)startAutoRefreshTimer
{
    [self stopAutoRefreshTimer];
    
    if([[UserSettings sharedUserSettings] refreshInterval] > 0) {
        self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:[[UserSettings sharedUserSettings] refreshInterval] target:self selector:@selector(autoRefreshTimerElapsed:) userInfo:nil repeats:YES];
    }
}

- (void)stopAutoRefreshTimer
{
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
}

@end
