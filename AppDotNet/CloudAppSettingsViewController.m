//
//  CloudAppSettingsViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "CloudAppSettingsViewController.h"
#import "CloudApp.h"

@interface CloudAppSettingsViewController() <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UIView *loginView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *loginBackgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *authenticatedCheckmarkImageView;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

-(void) shakeLoginView;

@end

@implementation CloudAppSettingsViewController
- (id)init
{
    self = [super initWithNibName:@"CloudAppSettingsViewController" bundle:nil];
    if(self) {
        self.title = @"CloudApp";
    }
    return self;
}

- (void)viewDidLoad
{
    self.backgroundImageView.image = [self.backgroundImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    UIImage *loginBackgroundImage = [UIImage imageNamed:@"login-background.png"];
    self.loginBackgroundImageView.image = [loginBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    self.usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"CloudAppUsername"];
    self.passwordField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"CloudAppPassword"];
    
    [[CloudApp sharedCloudApp] checkCredentialsWithCallback:^(BOOL succeeded) {
        if(succeeded) {
            self.authenticatedCheckmarkImageView.image = [UIImage imageNamed:@"checkmark-checked.png"];
        } else {
            self.authenticatedCheckmarkImageView.image = [UIImage imageNamed:@"checkmark-unchecked.png"];
        }
    }];

}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.usernameField) {
        if(self.usernameField.text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:self.usernameField.text forKey:@"CloudAppUsername"];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CloudAppUsername"];
        }
    } else if(textField == self.passwordField) {
        if(self.passwordField.text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"CloudAppPassword"];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CloudAppPassword"];
        }
    }
    
    // If both username and password have text, do an authentication call
    if(self.usernameField.text.length > 0 && self.passwordField.text.length > 0) {
        [[CloudApp sharedCloudApp] checkCredentialsWithCallback:^(BOOL succeeded) {
            NSLog(@"Authentication succeeded? %i", succeeded);
            if(succeeded) {
                self.authenticatedCheckmarkImageView.image = [UIImage imageNamed:@"checkmark-checked.png"];
            } else {
                self.authenticatedCheckmarkImageView.image = [UIImage imageNamed:@"checkmark-unchecked.png"];
            }
        }];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark Animations
-(void) shakeLoginView
{
    self.loginView.transform = CGAffineTransformMakeTranslation(-7, 0);
    
    [UIView animateWithDuration:0.06f animations:^ (void) {
        
        [UIView setAnimationRepeatCount:3.0];
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView setAnimationDelegate: self];
        
        self.loginView.transform = CGAffineTransformIdentity;
    } completion:nil];
}
@end
