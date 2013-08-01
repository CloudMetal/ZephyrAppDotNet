//
//  Pocket.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface Pocket : NSObject
+ (Pocket *)sharedPocket;

- (BOOL)canShareToPocket;
- (void)sendURLToPocket:(NSURL *)url title:(NSString *)title;
- (void)checkCredentialsWithCallback:(void (^)(BOOL succeeded))theCallback;
@end
