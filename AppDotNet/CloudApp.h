//
//  CloudApp.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface CloudApp : NSObject
+ (CloudApp *)sharedCloudApp;

- (void)sendImageToCloudApp:(UIImage *)image completionCallback:(void (^)(NSURL *url, BOOL succeeded))theCallback;
- (void)checkCredentialsWithCallback:(void (^)(BOOL succeeded))theCallback;
@end
