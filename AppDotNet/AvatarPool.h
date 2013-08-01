//
//  AvatarPool.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

extern NSString *AvatarPoolFinishedDownloadNotification;

@interface AvatarPool : NSObject
+ (AvatarPool *)sharedAvatarPool;

- (UIImage *)avatarImageForURL:(NSURL *)theURL;
@end
