//
//  SMTEDelegateController.h
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <UIKit/UIKit.h>

@interface SMTEDelegateController : NSObject <UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIWebViewDelegate, UISearchBarDelegate> {
}
@property (nonatomic, assign) id nextDelegate;
@property (nonatomic, assign) BOOL provideUndoSupport; // Default: YES

+ (BOOL)isTextExpanderTouchInstalled;
+ (BOOL)snippetsAreShared;
+ (void)setExpansionEnabled:(BOOL)expansionEnabled;
- (void)resetKeyLog;
- (void)willEnterForeground;

@end
