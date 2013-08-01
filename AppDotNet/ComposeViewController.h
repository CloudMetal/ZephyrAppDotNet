//
//  ComposeViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface ComposeViewController : UIViewController
@property (nonatomic, copy) NSString *replyUserName;
@property (nonatomic, copy) NSString *replyID;
@property (nonatomic, copy) NSString *replyText;
@property (nonatomic, copy) NSString *defaultText;
@property (nonatomic) BOOL shouldStartEditingFromBeginning;

- (void)presentInViewController:(UIViewController *)theViewController;
@end
