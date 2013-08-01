//
//  ActivityNotificationView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

typedef enum {
    ActivityNotificationViewStateRunning,
    ActivityNotificationViewStateAccepted,
    ActivityNotificationViewStateRejected,
} ActivityNotificationViewState;

@interface ActivityNotificationView : UIView
@property (nonatomic) ActivityNotificationViewState state;

- (void)showInWindow:(UIWindow *)theWindow animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
@end
