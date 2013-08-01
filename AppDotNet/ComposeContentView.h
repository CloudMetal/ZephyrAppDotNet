//
//  ComposeContentView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "InReplyToView.h"

@interface ComposeContentView : UIView
@property (nonatomic, strong) IBOutlet UILabel *replyToTextLabel;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet InReplyToView *inReplyToView;

@property (nonatomic, copy) NSString *replyToID;
@property (nonatomic, copy) NSString *replyToText;
@end
