//
//  APIAuthorization.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIAuthorization.h"

NSString *APIAuthorizationAccessTokenDidChangeNotification = @"APIAuthorizationAccessTokenDidChangeNotification";

@interface APIAuthorization()
@property (nonatomic, copy) NSArray *profiles;

- (NSDictionary *)profilePackDictionary;
- (void)unpackProfilePackDictionary:(NSDictionary *)theDictionary;
- (void)save;
- (NSURL *)profileDirectory;
- (NSURL *)profileDataPath;
@end

@implementation APIAuthorization
+ (APIAuthorization *)sharedAPIAuthorization
{
    static APIAuthorization *sharedAPIAuthorizationInstance = nil;
    if(!sharedAPIAuthorizationInstance) {
        sharedAPIAuthorizationInstance = [[APIAuthorization alloc] init];
    }
    return sharedAPIAuthorizationInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        if(!self.profiles) {
            self.profiles = [[NSArray alloc] init];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[[self profileDataPath] path]]) {
            [self unpackProfilePackDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[[self profileDataPath] path]]];
        }
        
        [self addObserver:self forKeyPath:@"profiles" options:0 context:0];
        [self addObserver:self forKeyPath:@"currentProfile" options:0 context:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileDidChange:) name:APIAuthorizationProfileDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"profiles"];
    [self removeObserver:self forKeyPath:@"currentProfile"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIAuthorizationProfileDidChangeNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"profiles"]) {
        [self save];
    } else if([keyPath isEqualToString:@"currentProfile"]) {
        [self save];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APIAuthorizationAccessTokenDidChangeNotification object:self];
    }
}

#pragma mark -
#pragma mark Notifications
- (void)profileDidChange:(NSNotification *)notification
{
    if([self.profiles containsObject:notification.object]) {
        [self save];
    }
    
    [self willChangeValueForKey:@"profiles"];
    [self didChangeValueForKey:@"profiles"];
}

#pragma mark -
#pragma mark Public API

- (void)addProfileWithAccessToken:(NSString *)theAccessToken
{
    NSAssert(theAccessToken != nil, @"Don't say that the user authorized and then give me a nil access token.");
    
    APIAuthorizationProfile *profile = [[APIAuthorizationProfile alloc] init];
    
    profile.accessToken = theAccessToken;
    
    self.profiles = [self.profiles arrayByAddingObject:profile];
    self.currentProfile = profile;
}

- (void)removeProfile:(APIAuthorizationProfile *)theProfile
{
    self.profiles = [self.profiles arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
        return theElement != theProfile;
    }];
}

- (void)setImage:(UIImage *)image forProfile:(APIAuthorizationProfile *)theProfile
{
    NSAssert(theProfile.userID != nil, @"Don't try setting an image for a nil user id");
    
    NSURL *url = [[self profileDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", theProfile.userID]];
    [UIImagePNGRepresentation(image) writeToURL:url atomically:YES];
    theProfile.localAvatarURL = url;
    
    // Saving should happen automatically through notifications
}

- (UIImage *)imageForProfile:(APIAuthorizationProfile *)theProfile
{
    return [UIImage imageWithContentsOfFile:[theProfile.localAvatarURL path]];
}

#pragma mark -
#pragma mark Private API
- (NSDictionary *)profilePackDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if(self.profiles) {
        [dictionary setObject:self.profiles forKey:@"profiles"];
    }
    
    if(self.currentProfile) {
        [dictionary setObject:self.currentProfile forKey:@"currentProfile"];
    }
    
    return dictionary;
}

- (void)unpackProfilePackDictionary:(NSDictionary *)theDictionary
{
    if([theDictionary objectForKey:@"profiles"]) {
        self.profiles = [theDictionary objectForKey:@"profiles"];
    }
    
    if([theDictionary objectForKey:@"currentProfile"]) {
        self.currentProfile = [theDictionary objectForKey:@"currentProfile"];
    }
}

- (void)save
{
    [NSKeyedArchiver archiveRootObject:[self profilePackDictionary] toFile:[[self profileDataPath] path]];
}

- (NSURL *)profileDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    NSString *profilePath = [path stringByAppendingPathComponent:@"Profiles"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:profilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:profilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [NSURL fileURLWithPath:profilePath];
}

- (NSURL *)profileDataPath
{
    NSURL *profileDirectory = [self profileDirectory];
    
    return [profileDirectory URLByAppendingPathComponent:@"Profiles.dat"];
}
@end
