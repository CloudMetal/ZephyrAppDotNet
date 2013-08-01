//
//  VDownload.h
//  Velvet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

#define kVDownloadStandardTimeout 30.0

typedef enum {
    VDownloadMethodGET = 0,
    VDownloadMethodPOST = 1,
    VDownloadMethodDELETE = 2,
} VDownloadMethod;

@class VDownload;

@protocol VDownloadDelegate <NSObject>
- (void)download:(VDownload *)theDownload finishedDownloadingData:(NSData *)theData;
- (void)downloadFailedToDownloadData:(VDownload *)theDownload;
@end

@interface VDownload : NSObject
@property (nonatomic, weak) id<VDownloadDelegate> delegate;
@property (nonatomic) VDownloadMethod method;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) NSDictionary *HTTPHeaderFields;
@property (nonatomic, copy) NSData *bodyData;
@property (nonatomic, strong) NSURLCredential *challengeCredential;

+ (VDownload *)startPOSTDownloadWithURL:(NSURL *)theURL parameters:(NSDictionary *)theParameters delegate:(id<VDownloadDelegate>)theDelegate;
+ (VDownload *)startPOSTDownloadWithURL:(NSURL *)theURL parameters:(NSDictionary *)theParameters timout:(NSTimeInterval)theTimeout delegate:(id<VDownloadDelegate>)theDelegate;

+ (VDownload *)startDownloadWithURL:(NSURL *)theURL delegate:(id<VDownloadDelegate>)theDelegate;
+ (VDownload *)startDownloadWithURL:(NSURL *)theURL timout:(NSTimeInterval)theTimeout delegate:(id<VDownloadDelegate>)theDelegate;

- (void)start;
- (void)cancel;
@end
