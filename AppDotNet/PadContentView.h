//
//  PadContentView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "PostStreamPassThroughView.h"

typedef enum {
    PadContentViewBackgroundStyleDefault = 0,
    PadContentViewBackgroundStyleDark = 1
} PadContentViewBackgroundStyle;

@interface PadContentView : UIView
@property (nonatomic, readonly, strong) PostStreamPassThroughView *passThroughView;
@property (nonatomic, strong) IBOutlet UIView *passThroughViewTarget;
@property (nonatomic) PadContentViewBackgroundStyle backgroundStyle;
@end
