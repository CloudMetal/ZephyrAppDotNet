//
//  Instapaper.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Instapaper.h"
#import "VDownload.h"

@interface Instapaper() <VDownloadDelegate>
@property (nonatomic, strong) NSMutableArray *downloads;
@property (nonatomic, strong) NSMutableArray *authenticationDownloads;
@property (nonatomic, strong) NSMutableArray *authenticationCallbacks;
@end

@implementation Instapaper
+ (Instapaper *)sharedInstapaper
{
    static Instapaper *instapaper = nil;
    if(!instapaper) {
        instapaper = [[Instapaper alloc] init];
    }
    return instapaper;
}

- (BOOL)canShareToInstapaper
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperUsername"] != nil &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"InstapaperAuthenticated"] == YES;
}

- (void)sendURLToInstapaper:(NSURL *)url
{
    if(!self.downloads) {
        self.downloads = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperUsername"] forKey:@"username"];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperPassword"]) {
        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperPassword"] forKey:@"password"];
    }
    
    [parameters setObject:[url absoluteString] forKey:@"url"];
    
    VDownload *download = [[VDownload alloc] init];
    download.url = [NSURL URLWithString:@"https://www.instapaper.com/api/add"];
    download.parameters = parameters;
    download.method = VDownloadMethodPOST;
    download.delegate = self;
    download.timeout = 10.0;
    [download start];
    
    [self.downloads addObject:download];
}

- (void)checkCredentialsWithCallback:(void (^)(BOOL succeeded))theCallback
{
    if(!self.authenticationDownloads) {
        self.authenticationDownloads = [[NSMutableArray alloc] init];
        self.authenticationCallbacks = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperUsername"] forKey:@"username"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperPassword"]) {
        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"InstapaperPassword"] forKey:@"password"];
    }
    
    VDownload *download = [[VDownload alloc] init];
    download.url = [NSURL URLWithString:@"https://www.instapaper.com/api/authenticate"];
    download.parameters = parameters;
    download.method = VDownloadMethodPOST;
    download.delegate = self;
    download.timeout = 10.0;
    [download start];
    
    [self.authenticationDownloads addObject:download];
    [self.authenticationCallbacks addObject:theCallback];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    if([self.downloads containsObject:theDownload]) {
        [self.downloads removeObject:theDownload];
    } else {
        NSUInteger index = [self.authenticationDownloads indexOfObject:theDownload];
        void (^ callback)(BOOL succeeded) = [self.authenticationCallbacks objectAtIndex:index];
        
        uint8_t zero = 0;
        NSMutableData *data = [NSMutableData dataWithData:theData];
        [data appendBytes:&zero length:sizeof(uint8_t)];
        
        NSString *string = [NSString stringWithCString:data.bytes encoding:NSUTF8StringEncoding];
        if([string isEqualToString:@"200"]) {
            callback(YES);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"InstapaperAuthenticated"];
        } else {
            NSLog(@"Instapaper check failed with string %@", string);
            
            callback(NO);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"InstapaperAuthenticated"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.authenticationDownloads removeObjectAtIndex:index];
        [self.authenticationCallbacks removeObjectAtIndex:index];
    }
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    if([self.downloads containsObject:theDownload]) {
        [self.downloads removeObject:theDownload];
    } else {
        NSUInteger index = [self.authenticationDownloads indexOfObject:theDownload];
        void (^ callback)(BOOL succeeded) = [self.authenticationCallbacks objectAtIndex:index];
        callback(NO);
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"InstapaperAuthenticated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.authenticationDownloads removeObjectAtIndex:index];
        [self.authenticationCallbacks removeObjectAtIndex:index];
    }
}
@end
