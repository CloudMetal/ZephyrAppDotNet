//
//  UnregisterForNotificationsCall.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UnregisterForNotificationsCall.h"
#import "VDownload.h"
#import <CommonCrypto/CommonDigest.h>

static NSMutableArray *unregisterCalls = nil;

@interface UnregisterForNotificationsCall() <VDownloadDelegate>
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, strong) VDownload *download;
- (void)call;
@end

@implementation UnregisterForNotificationsCall
+ (UnregisterForNotificationsCall *)unregisterForNotificationsWithUserID:(NSString *)theUserID token:(NSString *)theToken userName:(NSString *)theUserName callback:(UnregisterForNotificationsCallback)theCallback
{
    UnregisterForNotificationsCall *call = [[UnregisterForNotificationsCall alloc] init];
    
    call.userID = theUserID;
    call.token = theToken;
    call.userName = theUserName;
    call.callback = theCallback;
    
    [call call];
    
    return call;
}

- (NSString *)md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (void)call
{
    if(KeyFiberAppSignatureKey == nil) {
        NSLog(@"Unable to unsubscribe from push");
        return;
    }
    
    if(unregisterCalls == nil) {
        unregisterCalls = [[NSMutableArray alloc] init];
    }
    
    self.download = [[VDownload alloc] init];
    self.download.delegate = self;
    self.download.url = [NSURL URLWithString:@"https://getzephyrapp.com/api/notifications/unsubscribe"];
    self.download.method = VDownloadMethodPOST;
    
    NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
    [arguments setObject:self.userID forKey:@"user_id"];
    [arguments setObject:self.token forKey:@"apns_token"];
    [arguments setObject:self.userName forKey:@"username"];
    
    NSArray *keys = [[arguments allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *signatureText = @"";
    for(NSString *key in keys) {
        signatureText = [signatureText stringByAppendingString:key];
        signatureText = [signatureText stringByAppendingString:[arguments objectForKey:key]];
    }
    signatureText = [signatureText stringByAppendingString:KeyFiberAppSignatureKey];
    [arguments setObject:[self md5:signatureText] forKey:@"signature"];
    
    self.download.parameters = arguments;
    
    [self.download start];
    
    [unregisterCalls addObject:self];
}

#pragma mark -
#pragma mark VDownloadDelegate
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:theData options:0 error:0];
    if(json) {
        if([[json objectForKey:@"success"] integerValue] == 1) {
            self.callback(YES, nil);
        } else {
            self.callback(NO, nil);
        }
    } else {
        NSLog(@"Not valid json");
        NSMutableData *buffer = [[NSMutableData alloc] init];
        [buffer appendData:theData];
        unsigned char zero = '\0';
        [buffer appendBytes:&zero length:1];
        NSString *string = [[NSString alloc] initWithUTF8String:buffer.bytes];
        NSLog(@"%@", string);
        self.callback(NO, nil);
    }
    
    [unregisterCalls removeObject:self];
}

- (void)downloadFailedToDownloadData:(VDownload *)theDownload
{
    self.callback(NO, nil);
    
    [unregisterCalls removeObject:self];
}
@end
