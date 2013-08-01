//
//  UploadingView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface UploadingView : UIView
@property (nonatomic, copy) void (^uploadingViewDidCancelCallback)();

- (void)show;
- (void)dismiss;
@end
