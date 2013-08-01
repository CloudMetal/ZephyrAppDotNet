//
//  UsernamePool.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface UsernamePool : NSObject
+ (UsernamePool *)sharedUsernamePool;

- (void)addUsername:(NSString *)theUsername name:(NSString *)theName;
- (NSSet *)usernamesMatching:(NSString *)theString;
@end
