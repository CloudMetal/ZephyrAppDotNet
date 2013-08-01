//
//  PostStreamPassThroughView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostStreamPassThroughView.h"

@implementation PostStreamPassThroughView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *superHitTest = [super hitTest:point withEvent:event];
    if(superHitTest == self) {
        return self.passthroughView;
    }
    return superHitTest;
}
@end
