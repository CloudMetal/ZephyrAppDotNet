//
//  Yfrog.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Yfrog.h"
#import "VDownload.h"

@interface Yfrog() <VDownloadDelegate>
@property (nonatomic, strong) NSMutableArray *downloads;
@end

@implementation Yfrog
+ (Yfrog *)sharedYfrog
{
    static Yfrog *yfrogInstance = nil;
    if(!yfrogInstance) {
        yfrogInstance = [[Yfrog alloc] init];
    }
    return yfrogInstance;
}

- (void)sendImageToYfrog:(UIImage *)image completionCallback:(void (^)(NSURL *url, BOOL succeeded))theCallback
{
    if(!self.downloads) {
        self.downloads = [[NSMutableArray alloc] init];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *resized = [image scaledImageToPixelCount:1024 * 768];
        NSData *imageData = UIImageJPEGRepresentation(resized, 0.95);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(KeyYfrogAPIKey) {
                NSString *boundary = @"ABCDEFGHIJKLMNOPBoundary01010101101";
                
                VDownload *download = [[VDownload alloc] init];
                download.delegate = self;
                download.method = VDownloadMethodPOST;
                download.url = [NSURL URLWithString:@"http://www.imageshack.us/upload_api.php"];
                download.HTTPHeaderFields = @{ @"content-type" : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] };
                
                NSMutableData *bodyData = [[NSMutableData alloc] init];
                [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fileupload\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:imageData];
                [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\"\r\n\r\n%@", KeyYfrogAPIKey] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                download.bodyData = bodyData;
                
                NSDictionary *dictionary = @{ @"download" : download, @"callback" : theCallback };
                [self.downloads addObject:dictionary];
                
                [download start];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No YFrog API Key" message:@"You must add a yfrog API key to Keys.h in order to share to yfrog." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        });
    });
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    for(int i=0; i<self.downloads.count; i++) {
        NSDictionary *data = [self.downloads objectAtIndex:i];
        if([data objectForKey:@"download"] == theDownload) {
            void (^callback)(NSURL *url, BOOL succeeded) = [data objectForKey:@"callback"];
            
            uint8_t zero = '\0';
            NSMutableData *appendedData = [[NSMutableData alloc] initWithData:theData];
            [appendedData appendBytes:&zero length:sizeof(zero)];
            
            NSString *returnString = [NSString stringWithUTF8String:appendedData.bytes];
            NSURL *url = nil;
            NSUInteger openLocation = [returnString rangeOfString:@"<yfrog_link>"].location;
            NSUInteger closeLocation = [returnString rangeOfString:@"</yfrog_link>"].location;
            if(openLocation != NSNotFound && closeLocation != NSNotFound && closeLocation > openLocation) {
                openLocation += [@"<yfrog_link>" length];
                NSString *tag = [returnString substringWithRange:NSMakeRange(openLocation, closeLocation - openLocation)];
                if(tag.length > 0) {
                    url = [NSURL URLWithString:tag];
                }
            }
            
            callback(url, url != nil);
            
            [self.downloads removeObject:data];
            return;
        }
    }
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    for(int i=0; i<self.downloads.count; i++) {
        NSDictionary *data = [self.downloads objectAtIndex:i];
        if([data objectForKey:@"download"] == theDownload) {
            void (^callback)(NSURL *url, BOOL succeeded) = [data objectForKey:@"callback"];
            
            callback(nil, NO);
            
            [self.downloads removeObject:data];
            return;
        }
    }
}
@end
