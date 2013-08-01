//
//  Yfrog.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface Yfrog : NSObject
+ (Yfrog *)sharedYfrog;

- (void)sendImageToYfrog:(UIImage *)image completionCallback:(void (^)(NSURL *url, BOOL succeeded))theCallback;
@end
