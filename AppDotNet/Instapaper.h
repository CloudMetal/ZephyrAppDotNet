//
//  Instapaper.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface Instapaper : NSObject
+ (Instapaper *)sharedInstapaper;

- (BOOL)canShareToInstapaper;
- (void)sendURLToInstapaper:(NSURL *)url;
- (void)checkCredentialsWithCallback:(void (^)(BOOL succeeded))theCallback;
@end
