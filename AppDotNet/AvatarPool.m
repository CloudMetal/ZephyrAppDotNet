//
//  AvatarPool.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "AvatarPool.h"
#import "VDownload.h"
#import "PostTableViewCell.h"

#define kBackgroundAvatarCacheSize 50
#define kAvatarCacheSize 250

NSString *AvatarPoolFinishedDownloadNotification = @"AvatarPoolFinishedDownloadNotification";

@interface AvatarPool() <VDownloadDelegate>
@property (nonatomic, strong) NSMutableDictionary *pool;
@property (nonatomic, strong) NSMutableArray *cacheList;
@property (nonatomic, strong) VDownload *download;

- (void)downloadImageForURL:(NSURL *)url;
- (void)compactCacheToCount:(NSUInteger)count;
- (void)emptyCache;
@end

@implementation AvatarPool
+ (AvatarPool *)sharedAvatarPool
{
    static AvatarPool *sharedAvatarPoolInstance = nil;
    if(!sharedAvatarPoolInstance) {
        sharedAvatarPoolInstance = [[AvatarPool alloc] init];
    }
    
    return sharedAvatarPoolInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.pool = [[NSMutableDictionary alloc] init];
        self.cacheList = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

- (UIImage *)avatarImageForURL:(NSURL *)theURL
{
    if(!theURL) {
        return nil;
    }
    
    NSInteger size = PostTableViewCellGetAvatarSize() * [[UIScreen mainScreen] scale];
    
    NSString *urlString = [theURL absoluteString];
    urlString = [urlString stringByAppendingFormat:@"?w=%i&h=%i", size, size];
    theURL = [NSURL URLWithString:urlString];
    
    UIImage *image = [self.pool objectForKey:theURL];
    if(image) {
        return image;
    }
    
    [self downloadImageForURL:theURL];
    
    return nil;
}

#pragma mark -
#pragma mark Notifications
- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
    [self emptyCache];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self compactCacheToCount:kBackgroundAvatarCacheSize];
}

#pragma mark -
#pragma mark Private API
- (void)downloadImageForURL:(NSURL *)url
{
    if(self.download) {
        return;
    }
    
    VDownload *download = [[VDownload alloc] init];
    download.url = url;
    download.delegate = self;
    download.timeout = 5;
    
    self.download = download;
    
    [download start];
}

- (void)compactCacheToCount:(NSUInteger)count
{
    if(count < 10) {
        count = 10;
    }
    
    while(self.cacheList.count > count) {
        NSUInteger removeIndex = rand() % (count - 5);
        [self.pool removeObjectForKey:[self.cacheList objectAtIndex:removeIndex]];
        [self.cacheList removeObjectAtIndex:removeIndex];
    }
}

- (void)emptyCache
{
    [self.pool removeAllObjects];
    [self.cacheList removeAllObjects];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    self.download = nil;
    
    UIImage *image = [UIImage imageWithData:theData];
    
    if(image == nil) {
        image = [UIImage imageNamed:@"avatar-placeholder.png"];
    }
    
    if(image) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize()), YES, 0);
        [image drawInRect:CGRectMake(0, 0, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize())];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.pool setObject:image forKey:theDownload.url];
    }
    
    [self.cacheList addObject:theDownload.url];
    [self compactCacheToCount:kAvatarCacheSize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AvatarPoolFinishedDownloadNotification object:self];
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    self.download = nil;
    
    [self.pool setObject:[UIImage imageNamed:@"avatar-placeholder.png"] forKey:theDownload.url];
    
    [self.cacheList addObject:theDownload.url];
    [self compactCacheToCount:kAvatarCacheSize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AvatarPoolFinishedDownloadNotification object:self];
}
@end
