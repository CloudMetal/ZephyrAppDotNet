//
//  Pocket.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Pocket.h"
#import "VDownload.h"

@interface Pocket() <VDownloadDelegate>
@property (nonatomic, strong) NSMutableArray *downloads;
@property (nonatomic, strong) NSMutableArray *authenticationDownloads;
@property (nonatomic, strong) NSMutableArray *authenticationCallbacks;
@end

@implementation Pocket
+ (Pocket *)sharedPocket
{
    static Pocket *pocket = nil;
    if(!pocket) {
        pocket = [[Pocket alloc] init];
    }
    return pocket;
}

- (BOOL)canShareToPocket
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"PocketUsername"] != nil &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"PocketPassword"] != nil &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"PocketAuthenticated"] == YES;
}

- (void)sendURLToPocket:(NSURL *)url title:(NSString *)title
{
    if(title.length == 0) {
        title = nil;
    }
    
    if(!self.downloads) {
        self.downloads = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"PocketUsername"] forKey:@"username"];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"PocketPassword"] forKey:@"password"];
    
    if(title) {
        [parameters setObject:title forKey:@"title"];
    }
    
    [parameters setObject:[url absoluteString] forKey:@"url"];
    
    VDownload *download = [[VDownload alloc] init];
    download.url = [NSURL URLWithString:@"https://readitlaterlist.com/v2/add"];
    download.parameters = parameters;
    download.method = VDownloadMethodPOST;
    download.delegate = self;
    download.timeout = 10.0;
    [download start];
    
    [self.downloads addObject:download];
}

- (void)checkCredentialsWithCallback:(void (^)(BOOL succeeded))theCallback
{
    if(KeyPocketAPIKey) {
        if(!self.authenticationDownloads) {
            self.authenticationDownloads = [[NSMutableArray alloc] init];
            self.authenticationCallbacks = [[NSMutableArray alloc] init];
        }
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:KeyPocketAPIKey forKey:@"apikey"];
        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"PocketUsername"] forKey:@"username"];
        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"PocketPassword"] forKey:@"password"];
        
        VDownload *download = [[VDownload alloc] init];
        download.url = [NSURL URLWithString:@"https://readitlaterlist.com/v2/auth"];
        download.parameters = parameters;
        download.method = VDownloadMethodPOST;
        download.delegate = self;
        download.timeout = 10.0;
        [download start];
        
        [self.authenticationDownloads addObject:download];
        [self.authenticationCallbacks addObject:theCallback];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Pocket API Key" message:@"An API key for Pocket must be provied in Keys.h before you can share to pocket." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        theCallback(NO);
    }
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
        if([string isEqualToString:@"200 OK"]) {
            callback(YES);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PocketAuthenticated"];
        } else {
            NSLog(@"Pocket check failed with string %@", string);
            
            callback(NO);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PocketAuthenticated"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.authenticationDownloads removeObjectAtIndex:index];
        [self.authenticationCallbacks removeObjectAtIndex:index];
    }
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    NSLog(@"%@ failed to download", theDownload);
    
    if([self.downloads containsObject:theDownload]) {
        [self.downloads removeObject:theDownload];
    } else {
        NSUInteger index = [self.authenticationDownloads indexOfObject:theDownload];
        void (^ callback)(BOOL succeeded) = [self.authenticationCallbacks objectAtIndex:index];
        callback(NO);
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PocketAuthenticated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.authenticationDownloads removeObjectAtIndex:index];
        [self.authenticationCallbacks removeObjectAtIndex:index];
    }
}
@end
