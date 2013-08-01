//
//  AuthenticatedUser.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AuthenticatedUser.h"
#import "API.h"
#import "Reachability.h"
#import "VDownload.h"

@interface AuthenticatedUser() <VDownloadDelegate>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) VDownload *avatarDownload;

- (void)fetchAuthenticatedUser;
- (NSURL *)urlForSavedResource;
@end

@implementation AuthenticatedUser
+ (AuthenticatedUser *)sharedAuthenticatedUser
{
    static AuthenticatedUser *sharedAuthenticatedUserInstance = nil;
    if(!sharedAuthenticatedUserInstance) {
        sharedAuthenticatedUserInstance = [[AuthenticatedUser alloc] init];
    }
    return sharedAuthenticatedUserInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        if([[NSFileManager defaultManager] fileExistsAtPath:[[self urlForSavedResource] path]]) {
            self.user = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self urlForSavedResource] path]];
        }
        
        [self fetchAuthenticatedUser];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenDidChange:) name:APIAuthorizationAccessTokenDidChangeNotification object:nil];
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:self.reachability];
    }
    return self;
}

- (NSURL *)urlForSavedResource
{
    NSArray *applicationSupportDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *applicationSupportURL = [applicationSupportDirectories lastObject];
    [[NSFileManager defaultManager] createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [applicationSupportURL URLByAppendingPathComponent:[@"authenticatedUser" stringByAppendingPathExtension:@"user"]];
}

- (void)fetchAuthenticatedUser
{
    static NSInteger currentFetch = 0;
    
    if([[APIAuthorization sharedAPIAuthorization] currentProfile] == nil) {
        self.user = nil;
        
        if(self.avatarDownload) {
            self.avatarDownload.delegate = nil;
            [self.avatarDownload cancel];
            self.avatarDownload = nil;
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[[self urlForSavedResource] path]]) {
            [[NSFileManager defaultManager] removeItemAtURL:[self urlForSavedResource] error:nil];
        }
        return;
    }
    
    currentFetch++;
    NSInteger fetchForAuthorizationCount = currentFetch;
    
    [APITokenCheck checkTokenWithCompletionHandler:^(User *user, NSError *error) {
        if(fetchForAuthorizationCount != currentFetch) {
            return;
        }
        
        if(![user.userID isEqual:self.user.userID]) {
            self.user = user;
            
            [NSKeyedArchiver archiveRootObject:self.user toFile:[[self urlForSavedResource] path]];
            [[self urlForSavedResource] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:0];
            
            if(self.avatarDownload) {
                self.avatarDownload.delegate = nil;
                [self.avatarDownload cancel];
                self.avatarDownload = nil;
            }
            
            self.avatarDownload = [VDownload startDownloadWithURL:self.user.avatarImage.url delegate:self];
        }
        
        if(self.user) {
            APIAuthorizationProfile *profile = [[APIAuthorization sharedAPIAuthorization] currentProfile];
            profile.userID = self.user.userID;
            profile.user = self.user.name;
            profile.userName = self.user.userName;
        }
    }];
}

- (void)accessTokenDidChange:(NSNotification *)notification
{
    [self fetchAuthenticatedUser];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    NSLog(@"Reachability changed");
    [self fetchAuthenticatedUser];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    UIImage *image = [[UIImage alloc] initWithData:theData];
    
    if(image) {
        APIAuthorizationProfile *profile = [[APIAuthorization sharedAPIAuthorization] currentProfile];
        [[APIAuthorization sharedAPIAuthorization] setImage:image forProfile:profile];
    }
    
    self.avatarDownload = nil;
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    self.avatarDownload = nil;
}
@end
