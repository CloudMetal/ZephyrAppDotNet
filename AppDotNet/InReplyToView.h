//
//  InReplyToView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface InReplyToView : UIView
@property (nonatomic, copy) NSString *replyID;

@property (nonatomic, copy) void (^panBlock)(CGFloat amount);
@property (nonatomic, copy) void (^panFinishedBlock)();
@end
