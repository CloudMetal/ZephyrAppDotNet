//
//  VDownload.m
//  Velvet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "VDownload.h"
#import "NetworkActivityController.h"

@interface VDownload() <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;

- (NSString *)queryStringFromParameters;
@end

@implementation VDownload
#pragma mark -
#pragma mark Lifecycle
- (id)init
{
    self = [super init];
    if(self) {
        self.method = VDownloadMethodGET;
        self.timeout = kVDownloadStandardTimeout;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
    self.connection = nil;
}

#pragma mark -
#pragma mark Class Methods
+ (VDownload *)startPOSTDownloadWithURL:(NSURL *)theURL parameters:(NSDictionary *)theParameters delegate:(id<VDownloadDelegate>)theDelegate
{
    return [VDownload startPOSTDownloadWithURL:theURL parameters:theParameters timout:kVDownloadStandardTimeout delegate:theDelegate];
}

+ (VDownload *)startPOSTDownloadWithURL:(NSURL *)theURL parameters:(NSDictionary *)theParameters timout:(NSTimeInterval)theTimeout delegate:(id<VDownloadDelegate>)theDelegate
{
    VDownload *download = [[VDownload alloc] init];
    
    download.method = VDownloadMethodPOST;
    download.url = theURL;
    download.parameters = theParameters;
    download.timeout = theTimeout;
    download.delegate = theDelegate;
    
    [download start];
    
    return download;
}

+ (VDownload *)startDownloadWithURL:(NSURL *)theURL delegate:(id<VDownloadDelegate>)theDelegate
{
    return [VDownload startDownloadWithURL:theURL timout:kVDownloadStandardTimeout delegate:theDelegate];
}

+ (VDownload *)startDownloadWithURL:(NSURL *)theURL timout:(NSTimeInterval)theTimeout delegate:(id<VDownloadDelegate>)theDelegate
{
    VDownload *download = [[VDownload alloc] init];
    
    download.method = VDownloadMethodGET;
    download.url = theURL;
    download.timeout = theTimeout;
    download.delegate = theDelegate;
    
    [download start];
    
    return download;
}

#pragma mark -
#pragma mark Private API
- (NSString *)queryStringFromParameters
{
    NSMutableArray *pairs = [[NSMutableArray alloc] init];
    
    for(NSString *key in self.parameters) {
        NSString *value = [self.parameters objectForKey:key];
        if(![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        NSString *pair = [NSString stringWithFormat:@"%@=%@", key, [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [pairs addObject:pair];
    }
    
    if(pairs.count == 0) {
        return @"";
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

#pragma mark -
#pragma mark Public API
- (void)start
{
    if(self.connection) {
        [NSException raise:NSGenericException format:@"Cannot start a download that is already in progress."];
    }
    
    if(self.url == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot start a download without a URL."];
    }
    
    [[NetworkActivityController sharedNetworkActivityController] addNetworkActivity];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeout];
    NSString *queryString = nil;
    NSData *queryData = nil;
    switch (self.method) {
        case VDownloadMethodGET:
            [request setHTTPMethod:@"GET"];
            for(NSString *HTTPHeaderField in self.HTTPHeaderFields) {
                [request setValue:[self.HTTPHeaderFields objectForKey:HTTPHeaderField] forHTTPHeaderField:HTTPHeaderField];
            }
            queryString = [self queryStringFromParameters];
            if(queryString.length > 0) {
                if([self.url.absoluteString rangeOfString:@"?"].location == NSNotFound) {
                    request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.url.absoluteString, queryString]];
                } else {
                    request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", self.url.absoluteString, queryString]];
                }
            }
            break;
        case VDownloadMethodPOST:
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            for(NSString *HTTPHeaderField in self.HTTPHeaderFields) {
                [request setValue:[self.HTTPHeaderFields objectForKey:HTTPHeaderField] forHTTPHeaderField:HTTPHeaderField];
            }
            queryString = [self queryStringFromParameters];
            queryData = [NSData dataWithBytes:[queryString UTF8String] length:queryString.length];
            [request setHTTPBody:queryData];
            if(self.bodyData) {
                [request setHTTPBody:self.bodyData];
            }
            break;
        case VDownloadMethodDELETE:
            [request setHTTPMethod:@"DELETE"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            for(NSString *HTTPHeaderField in self.HTTPHeaderFields) {
                [request setValue:[self.HTTPHeaderFields objectForKey:HTTPHeaderField] forHTTPHeaderField:HTTPHeaderField];
            }
            queryString = [self queryStringFromParameters]; 
            queryData = [NSData dataWithBytes:[queryString UTF8String] length:queryString.length];
            [request setHTTPBody:queryData];
            if(self.bodyData) {
                [request setHTTPBody:self.bodyData];
            }
            break;
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unrecognized download method"];
            break;
    }
    
    self.data = [[NSMutableData alloc] init];
    //self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel
{
    if(self.connection) {
        [[NetworkActivityController sharedNetworkActivityController] removeNetworkActivity];
    }
    
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if([challenge previousFailureCount] == 0 && self.challengeCredential != nil) {
        [[challenge sender] useCredential:self.challengeCredential forAuthenticationChallenge:challenge];
    } else {
        [self cancel];
        [self.delegate downloadFailedToDownloadData:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[NetworkActivityController sharedNetworkActivityController] removeNetworkActivity];
    
    self.connection = nil;
    
    [self.data setLength:0];
    [self.delegate downloadFailedToDownloadData:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[NetworkActivityController sharedNetworkActivityController] removeNetworkActivity];
    
    self.connection = nil;
    
    [self.delegate download:self finishedDownloadingData:self.data];
}

@end
