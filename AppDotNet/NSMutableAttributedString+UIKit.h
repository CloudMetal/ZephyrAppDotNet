//
//  NSAttributedString+UIKit.h
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (UIKit)
- (void)addFontAttribute:(UIFont *)font range:(NSRange)range;
- (void)addColorAttribute:(UIColor *)color range:(NSRange)range;
@end
