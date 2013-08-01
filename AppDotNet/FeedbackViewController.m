//
//  FeedbackViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController()
@property (nonatomic, strong) IBOutlet UITextView *textView;
@end

@implementation FeedbackViewController
- (id)init
{
    self = [super initWithNibName:@"FeedbackViewController" bundle:nil];
    if(self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.textView becomeFirstResponder];
}
@end
