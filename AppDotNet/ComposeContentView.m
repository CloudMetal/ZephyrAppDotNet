//
//  ComposeContentView.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ComposeContentView.h"

@interface ComposeContentView()
- (void)relayout;
@end

@implementation ComposeContentView
- (void)awakeFromNib
{
    [self relayout];
    
    [self addObserver:self forKeyPath:@"replyToID" options:0 context:0];
    [self addObserver:self forKeyPath:@"replyToText" options:0 context:0];
    
    self.backgroundColor = [UIColor postBackgroundColor];
    self.replyToTextLabel.textColor = [UIColor postBodyTextColor];
    
    __weak ComposeContentView *composeContentView = self;
    self.inReplyToView.panBlock = ^(CGFloat amount) {
        composeContentView.replyToTextLabel.transform = CGAffineTransformMakeTranslation(0, amount * 0.5);
        composeContentView.textView.transform = CGAffineTransformMakeTranslation(0, amount * 0.5);
        composeContentView.inReplyToView.transform = CGAffineTransformMakeTranslation(0, amount * 0.5);
    };
    
    self.inReplyToView.panFinishedBlock = ^{
        [UIView animateWithDuration:0.33 animations:^{
            composeContentView.replyToTextLabel.transform = CGAffineTransformIdentity;
            composeContentView.textView.transform = CGAffineTransformIdentity;
            composeContentView.inReplyToView.transform = CGAffineTransformIdentity;
        }];
    };
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"replyToID"];
    [self removeObserver:self forKeyPath:@"replyToText"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"replyToID"]) {
        [self relayout];
    } else if([keyPath isEqualToString:@"replyToText"]) {
        [self relayout];
    }
}

- (void)relayout
{
    if(self.replyToID == nil) {
        self.replyToTextLabel.hidden = YES;
        self.inReplyToView.hidden = YES;
        
        self.inReplyToView.frame = CGRectMake(0, -self.inReplyToView.frame.size.height, self.bounds.size.width, self.inReplyToView.frame.size.height);
        self.textView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    } else {
        self.replyToTextLabel.hidden = NO;
        self.inReplyToView.hidden = NO;
        self.inReplyToView.replyID = self.replyToID;
        self.replyToTextLabel.text = self.replyToText;
        
        CGFloat replyToTextHeight = [self.replyToText sizeWithFont:self.replyToTextLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width - 20, 1024) lineBreakMode:UILineBreakModeCharacterWrap].height + 20;
        
        self.replyToTextLabel.frame = CGRectMake(10, -replyToTextHeight, self.bounds.size.width - 20, replyToTextHeight);
        self.inReplyToView.frame = CGRectMake(0, 0, self.bounds.size.width, self.inReplyToView.frame.size.height);
        self.textView.frame = CGRectMake(0, self.inReplyToView.frame.size.height, self.bounds.size.width, self.bounds.size.height - self.inReplyToView.frame.size.height);
    }
}
@end
