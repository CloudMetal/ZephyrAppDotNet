//
//  CloudApp.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "CloudApp.h"
#import "VDownload.h"

@interface CloudApp() <VDownloadDelegate>
@property (nonatomic, strong) NSMutableArray *downloads;
@end

@implementation CloudApp
+ (CloudApp *)sharedCloudApp
{
    static CloudApp *cloudAppInstance = nil;
    if(!cloudAppInstance) {
        cloudAppInstance = [[CloudApp alloc] init];
    }
    return cloudAppInstance;
}

- (void)sendImageToCloudApp:(UIImage *)image completionCallback:(void (^)(NSURL *url, BOOL succeeded))theCallback
{
    if(!self.downloads) {
        self.downloads = [[NSMutableArray alloc] init];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *resized = [image scaledImageToPixelCount:1024 * 768];
        NSData *imageData = UIImageJPEGRepresentation(resized, 0.95);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            VDownload *download = [[VDownload alloc] init];
            download.challengeCredential = [[NSURLCredential alloc] initWithUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"CloudAppUsername"] password:[[NSUserDefaults standardUserDefaults] objectForKey:@"CloudAppPassword"] persistence:NSURLCredentialPersistenceNone];
            download.delegate = self;
            download.method = VDownloadMethodGET;
            download.url = [NSURL URLWithString:@"http://my.cl.ly/items/new"];
            download.HTTPHeaderFields = @{ @"Accept" : @"application/json" };
            
            NSDictionary *dictionary = @{ @"download" : download, @"mode" : @0, @"imageData" : imageData, @"callback" : theCallback };
            [self.downloads addObject:dictionary];
            
            [download start];
        });
    });
}

- (void)checkCredentialsWithCallback:(void (^)(BOOL succeeded))theCallback
{
    if(!self.downloads) {
        self.downloads = [[NSMutableArray alloc] init];
    }
    
    VDownload *download = [[VDownload alloc] init];
    download.challengeCredential = [[NSURLCredential alloc] initWithUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"CloudAppUsername"] password:[[NSUserDefaults standardUserDefaults] objectForKey:@"CloudAppPassword"] persistence:NSURLCredentialPersistenceNone];
    download.delegate = self;
    download.method = VDownloadMethodGET;
    download.url = [NSURL URLWithString:@"http://my.cl.ly/account/stats"];
    download.HTTPHeaderFields = @{ @"Accept" : @"application/json" };
    
    NSDictionary *dictionary = @{ @"download" : download, @"mode" : @2, @"callback" : theCallback };
    [self.downloads addObject:dictionary];
    
    [download start];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    for(int i=0; i<self.downloads.count; i++) {
        NSDictionary *data = [self.downloads objectAtIndex:i];
        if([data objectForKey:@"download"] == theDownload) {
            if([[data objectForKey:@"mode"] integerValue] == 0) {
                [self.downloads removeObject:data];
                
                NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:theData options:0 error:0];
                
                if(([payload objectForKey:@"uploads_remaining"] != nil && [[payload objectForKey:@"uploads_remaining"] integerValue] == 0)) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload Limit Reached" message:@"You cannot upload new files to CloudApp for the rest of the day." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    
                    void (^callback)(NSURL *url, BOOL succeeded) = [data objectForKey:@"callback"];
                    callback(nil, NO);
                    
                    return;
                } else if([payload objectForKey:@"params"] == nil) {
                    void (^callback)(NSURL *url, BOOL succeeded) = [data objectForKey:@"callback"];
                    callback(nil, NO);
                    
                    return;
                }
                
                NSString *boundary = @"ABCDEFGHIJKLMNOPBoundary01010101101";
                
                VDownload *download = [[VDownload alloc] init];
                download.delegate = self;
                download.method = VDownloadMethodPOST;
                download.url = [NSURL URLWithString:[payload objectForKey:@"url"]];
                download.HTTPHeaderFields = @{ @"Accept" : @"application/json", @"content-type" : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] };
                
                NSMutableData *bodyData = [[NSMutableData alloc] init];
                [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                for(NSString *key in [payload objectForKey:@"params"]) {
                    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, [[payload objectForKey:@"params"] objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
                    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:[data objectForKey:@"imageData"]];
                [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                download.bodyData = bodyData;
                
                NSDictionary *dictionary = @{ @"download" : download, @"mode" : @1, @"callback" : [data objectForKey:@"callback"] };
                [self.downloads addObject:dictionary];
                
                [download start];
                
                return;
            } else if([[data objectForKey:@"mode"] integerValue] == 1) {
                void (^callback)(NSURL *url, BOOL succeeded) = [data objectForKey:@"callback"];
                
                NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:theData options:0 error:0];
                
                NSURL *url = nil;
                
                if([payload objectForKey:@"url"]) {
                    url = [NSURL URLWithString:[payload objectForKey:@"url"]];
                }
                
                callback(url, url != nil);
                
                [self.downloads removeObject:data];
                return;
            } else if([[data objectForKey:@"mode"] integerValue] == 2) {
                NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:theData options:0 error:0];
                
                void (^callback)(BOOL succeeded) = [data objectForKey:@"callback"];
                
                callback([payload objectForKey:@"items"] != nil);
                
                [self.downloads removeObject:data];
                return;
            }
        }
    }
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    for(int i=0; i<self.downloads.count; i++) {
        NSDictionary *data = [self.downloads objectAtIndex:i];
        if([data objectForKey:@"download"] == theDownload) {
            NSInteger mode = [[data objectForKey:@"mode"] integerValue];
            if(mode == 0 || mode == 1) {
                void (^callback)(NSURL *url, BOOL succeeded) = [data objectForKey:@"callback"];
                
                callback(nil, NO);
                
                [self.downloads removeObject:data];
                return;
            } else if(mode == 2) {
                void (^callback)(BOOL succeeded) = [data objectForKey:@"callback"];
                
                callback(NO);
                
                [self.downloads removeObject:data];
                return;
            }
        }
    }
}
@end
