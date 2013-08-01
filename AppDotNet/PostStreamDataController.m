//
//  PostStreamDataController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostStreamDataController.h"
#import "AuthenticatedUser.h"
#import "UserSettings.h"
#import "UserPersonalStreamConfiguration.h"
#import "UnifiedStreamConfiguration.h"

@interface PostStreamDataController()
@property (nonatomic) BOOL isShutdown;
@property (nonatomic) NSDate *dateOfLastLoad;

@property (nonatomic) BOOL shouldLoadInitialUponVisible;
@property (nonatomic) BOOL shouldRefreshUponVisible;
@property (nonatomic) BOOL shouldReloadAndRefreshUponVisible;

@property (nonatomic) BOOL restoringFromDisk;
@property (nonatomic) BOOL loading;
@property (nonatomic, strong) PostStreamData *data;

@property (nonatomic, strong) AuthenticatedUser *authenticatedUser;

- (NSURL *)urlForSavedResource;

- (void)loadInitial;
@end

@implementation PostStreamDataController
- (id)init
{
    self = [super init];
    if(self) {
        self.authenticatedUser = [AuthenticatedUser sharedAuthenticatedUser];
        self.numberOfPostsToInitiallyLoad = 20;
        
        self.data = [[PostStreamData alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.configuration.savesPosts && [[NSFileManager defaultManager] fileExistsAtPath:[[self urlForSavedResource] path]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:PostStreamDataDidUpdateNotification object:self.data];
                
                self.restoringFromDisk = YES;
                self.data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self urlForSavedResource] path]];
                self.restoringFromDisk = NO;
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:[self.configuration.savedStreamName stringByAppendingString:@"LastReadID"]]) {
                    self.data.lastReadPostID = [[NSUserDefaults standardUserDefaults] objectForKey:[self.configuration.savedStreamName stringByAppendingString:@"LastReadID"]];
                }
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:[self.configuration.savedStreamName stringByAppendingString:@"CurrentFocusID"]]) {
                    self.data.currentFocusPostID = [[NSUserDefaults standardUserDefaults] objectForKey:[self.configuration.savedStreamName stringByAppendingString:@"CurrentFocusID"]];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PostStreamDataDidUpdateNotification object:self.data];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postStreamDataDidUpdate:) name:PostStreamDataDidUpdateNotification object:self.data];
                
                [self reloadAndRefreshStream];
            } else {
                [self loadInitial];
            }
        });
        
        [self addObserver:self forKeyPath:@"isViewVisible" options:0 context:0];
        [self addObserver:self forKeyPath:@"loading" options:0 context:0];
        [self addObserver:self forKeyPath:@"authenticatedUser.user" options:0 context:0];
        [self addObserver:self forKeyPath:@"data.lastReadPostID" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"data.currentFocusPostID" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postStreamDataDidUpdate:) name:PostStreamDataDidUpdateNotification object:self.data];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationDidChange:) name:APIAuthorizationAccessTokenDidChangeNotification object:[APIAuthorization sharedAPIAuthorization]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPushNotification:) name:ADNUIApplicationDidReceivePushNotificationNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoRefreshIntervalPassed:) name:ADNUIApplicationAutoRefreshIntervalPassedNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isViewVisible"];
    [self removeObserver:self forKeyPath:@"loading"];
    [self removeObserver:self forKeyPath:@"authenticatedUser.user"];
    [self removeObserver:self forKeyPath:@"data.lastReadPostID"];
    [self removeObserver:self forKeyPath:@"data.currentFocusPostID"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PostStreamDataDidUpdateNotification object:self.data];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APIAuthorizationAccessTokenDidChangeNotification object:[APIAuthorization sharedAPIAuthorization]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADNUIApplicationDidReceivePushNotificationNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADNUIApplicationAutoRefreshIntervalPassedNotification object:[UIApplication sharedApplication]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"isViewVisible"]) {
        if(self.isViewVisible && self.configuration.shouldOnlyAutoRefreshWhenVisible) {
            if(self.shouldLoadInitialUponVisible) {
                [self loadInitial];
            } else if(self.shouldReloadAndRefreshUponVisible) {
                [self reloadAndRefreshStream];
            } else if(self.shouldRefreshUponVisible) {
                [self refreshStream];
            }
            
            self.shouldLoadInitialUponVisible = NO;
            self.shouldReloadAndRefreshUponVisible = NO;
            self.shouldRefreshUponVisible = NO;
        }
    } else if([keyPath isEqualToString:@"loading"]) {
        if(self.loading == NO) {
            self.dateOfLastLoad = [NSDate date];
        }
    } else if([keyPath isEqualToString:@"authenticatedUser.user"]) {
        [self loadInitial];
    } else if([keyPath isEqualToString:@"data.lastReadPostID"]) {
        if(![[change objectForKey:NSKeyValueChangeOldKey] isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {
            if(self.configuration.savesPosts && !self.restoringFromDisk) {
                [[NSUserDefaults standardUserDefaults] setObject:self.data.lastReadPostID forKey:[self.configuration.savedStreamName stringByAppendingString:@"LastReadID"]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } else if([keyPath isEqualToString:@"data.currentFocusPostID"]) {
        if(self.configuration.savesPosts && !self.restoringFromDisk) {
            if(![[change objectForKey:NSKeyValueChangeOldKey] isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {
                [[NSUserDefaults standardUserDefaults] setObject:self.data.currentFocusPostID forKey:[self.configuration.savedStreamName stringByAppendingString:@"CurrentFocusID"]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

#pragma mark -
#pragma mark Notifications
- (void)postStreamDataDidUpdate:(NSNotification *)notification
{
    if(self.configuration.savesPosts) {
        PostStreamData *dataCopy = [self.data copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataCopy];
            
            [data writeToURL:[self urlForSavedResource] atomically:YES];
            [[self urlForSavedResource] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:0];
        });
    }
}

- (void)authenticationDidChange:(NSNotification *)notification
{
    [self loadInitial];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self refreshStream];
}

- (void)receivedPushNotification:(NSNotification *)notification
{
    [self refreshStream];
}

- (void)autoRefreshIntervalPassed:(NSNotification *)notification
{
    if(self.dateOfLastLoad) {
        if(fabs([self.dateOfLastLoad timeIntervalSinceNow]) > [[UserSettings sharedUserSettings] refreshInterval] * 0.66) {
            [self refreshStream];
        }
    } else {
        [self refreshStream];
    }
}

#pragma mark -
#pragma mark Public API
- (void)shutdown
{
    self.isShutdown = YES;
}

- (void)refreshStream
{
    if(self.loading || self.isShutdown) {
        return;
    }
    
    if(![[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        return;
    }
    
    if((self.isViewVisible == NO) && (self.configuration.shouldOnlyAutoRefreshWhenVisible == YES)) {
        self.shouldRefreshUponVisible = YES;
        return;
    }
    
    if(self.authenticatedUser.user == nil) {
        return;
    }
    
    self.loading = YES;
    
    APIPostParameters *parameters = [[APIPostParameters alloc] init];
    parameters.flags = APIPostParameterFlagsDoNotIncludeDeleted;
    parameters.sinceID = self.data.maxPostID;
    parameters.countOfPosts = 100;
    
    if([[UserSettings sharedUserSettings] showDirectedPostsInUserStream] && ([self.configuration isKindOfClass:[UserPersonalStreamConfiguration class]] || [self.configuration isKindOfClass:[UnifiedStreamConfiguration class]])) {
        parameters.flags |= APIPostParameterFlagsIncludeDirectedPosts;
    }
    
    self.apiCallMaker(parameters, ^(NSArray *posts, PostListMetadata *meta, NSError *error) {
        self.loading = NO;
        
        [self.data insertPostsToFront:posts hasMore:meta.hasMore marker:meta.streamMarker];
    });
}

- (void)reloadAndRefreshStream
{
    if(self.loading || self.isShutdown) {
        return;
    }
    
    if(![[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        return;
    }
    
    if((self.isViewVisible == NO) && (self.configuration.shouldOnlyAutoRefreshWhenVisible == YES)) {
        self.shouldReloadAndRefreshUponVisible = YES;
        return;
    }
    
    if(self.authenticatedUser.user == nil) {
        return;
    }
    
    self.loading = YES;
    
    APIPostParameters *parameters = [[APIPostParameters alloc] init];
    parameters.flags = APIPostParameterFlagsDoNotIncludeDeleted;
    parameters.sinceID = self.data.minPostID;
    parameters.countOfPosts = 100;
    
    if([[UserSettings sharedUserSettings] showDirectedPostsInUserStream] && ([self.configuration isKindOfClass:[UserPersonalStreamConfiguration class]] || [self.configuration isKindOfClass:[UnifiedStreamConfiguration class]])) {
        parameters.flags |= APIPostParameterFlagsIncludeDirectedPosts;
    }
    
    if(self.data.currentFocusPostID) {
        NSUInteger currentFocusPostIndex = 0;
        for(NSUInteger i=0; i<self.data.countOfElements; i++) {
            if([self.data elementTypeAtIndex:i] == PostStreamElementTypePost) {
                Post *post = [self.data postAtIndex:i];
                if([post.postID isEqual:self.data.currentFocusPostID]) {
                    currentFocusPostIndex = i;
                    break;
                }
            }
        }
        
        for(int i=0; i<21; i++) {
            if(currentFocusPostIndex + i >= self.data.countOfElements) {
                break;
            }
            
            if([self.data elementTypeAtIndex:currentFocusPostIndex + i] == PostStreamElementTypePost) {
                Post *post = [self.data postAtIndex:currentFocusPostIndex + i];
                parameters.sinceID = post.postID;
            }
        }
    }
    
    if(parameters.sinceID) {
        parameters.sinceID = [NSString stringWithFormat:@"%lli", [self.data.minPostID longLongValue] - 1];
    }
    
    self.apiCallMaker(parameters, ^(NSArray *posts, PostListMetadata *meta, NSError *error) {
        self.loading = NO;
        
        [self.data setPosts:posts hasMore:self.data.hasMorePostsAtEndOfStream marker:meta.streamMarker];
    });
}

- (void)loadMore
{
    if(self.loading || self.isShutdown) {
        return;
    }
    
    if(![[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        return;
    }
    
    if(self.authenticatedUser.user == nil) {
        return;
    }
    
    self.loading = YES;
    
    APIPostParameters *parameters = [[APIPostParameters alloc] init];
    parameters.flags = APIPostParameterFlagsDoNotIncludeDeleted;
    parameters.beforeID = [self.data minPostID];
    
    if([[UserSettings sharedUserSettings] showDirectedPostsInUserStream] && ([self.configuration isKindOfClass:[UserPersonalStreamConfiguration class]] || [self.configuration isKindOfClass:[UnifiedStreamConfiguration class]])) {
        parameters.flags |= APIPostParameterFlagsIncludeDirectedPosts;
    }
    
    self.apiCallMaker(parameters, ^(NSArray *posts, PostListMetadata *meta, NSError *error) {
        self.loading = NO;
        
        [self.data addPostsToEnd:posts hasMore:meta.hasMore marker:meta.streamMarker];
    });
}

- (NSURL *)urlForSavedResource
{
    NSArray *applicationSupportDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *applicationSupportURL = [applicationSupportDirectories lastObject];
    [[NSFileManager defaultManager] createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSAssert(self.configuration.savedStreamName != nil, @"Must have saved stream name");
    
    return [applicationSupportURL URLByAppendingPathComponent:[self.configuration.savedStreamName stringByAppendingPathExtension:@"posts"]];
}

- (void)loadInitial
{
    if(self.loading || self.isShutdown) {
        return;
    }
    
    if(![[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        return;
    }
    
    if((self.isViewVisible == NO) && (self.configuration.shouldOnlyAutoRefreshWhenVisible == YES)) {
        self.shouldLoadInitialUponVisible = YES;
        return;
    }
    
    if(self.authenticatedUser.user == nil) {
        return;
    }
    
    self.loading = YES;
    
    [self.data setPosts:[NSArray array] hasMore:NO marker:nil];
    
    APIPostParameters *parameters = [[APIPostParameters alloc] init];
    parameters.flags = APIPostParameterFlagsDoNotIncludeDeleted;
    parameters.countOfPosts = self.numberOfPostsToInitiallyLoad;
    
    if([[UserSettings sharedUserSettings] showDirectedPostsInUserStream] && ([self.configuration isKindOfClass:[UserPersonalStreamConfiguration class]] || [self.configuration isKindOfClass:[UnifiedStreamConfiguration class]])) {
        parameters.flags |= APIPostParameterFlagsIncludeDirectedPosts;
    }
    
    self.apiCallMaker(parameters, ^(NSArray *posts, PostListMetadata *meta, NSError *error) {
        self.loading = NO;
        
        [self.data setPosts:posts hasMore:meta.hasMore marker:meta.streamMarker];
        self.data.lastReadPostID = self.data.maxPostID;
    });
}

- (void)loadMissingCellsFromBreakAtIndex:(NSUInteger)theBreakIndex
{
    NSAssert([self.data elementTypeAtIndex:theBreakIndex] == PostStreamElementTypeBreakMarker, @"Asking to load from something other than a break marker");
    
    if(self.loading || self.isShutdown) {
        return;
    }
    
    if(![[APIAuthorization sharedAPIAuthorization] currentProfile]) {
        return;
    }
    
    if(self.authenticatedUser.user == nil) {
        return;
    }
    
    self.loading = YES;
    
    APIPostParameters *parameters = [[APIPostParameters alloc] init];
    parameters.flags = APIPostParameterFlagsDoNotIncludeDeleted;
    parameters.countOfPosts = 100;
    parameters.beforeID = [[self.data postAtIndex:theBreakIndex - 1] postID];
    parameters.sinceID = [[self.data postAtIndex:theBreakIndex + 1] postID];
    
    if([[UserSettings sharedUserSettings] showDirectedPostsInUserStream] && ([self.configuration isKindOfClass:[UserPersonalStreamConfiguration class]] || [self.configuration isKindOfClass:[UnifiedStreamConfiguration class]])) {
        parameters.flags |= APIPostParameterFlagsIncludeDirectedPosts;
    }
    
    self.apiCallMaker(parameters, ^(NSArray *posts, PostListMetadata *meta, NSError *error) {
        self.loading = NO;
        
        [self.data insertPosts:posts beforeBreakMarkerAtIndex:theBreakIndex hasMore:meta.hasMore marker:meta.streamMarker];
    });
}
@end
