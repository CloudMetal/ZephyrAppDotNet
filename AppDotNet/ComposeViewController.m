//
//  ComposeViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "ComposeViewController.h"
#import "DraftsViewController.h"
#import "API.h"
#import "UsernamePool.h"
#import "HashtagPool.h"
#import "Drafts.h"
#import "SMTEDelegateController.h"
#import "ImageConfirmViewController.h"
#import "UserSettings.h"
#import "SuggestionView.h"
#import "UploadingView.h"
#import "ComposeContentView.h"
#import "ActivityNotificationView.h"

#import "Yfrog.h"
#import "CloudApp.h"

#define kTakePhotoButtonTitle @"Take Photo"
#define kChooseExistingButtonTitle @"Choose Existing"
#define kComposeSaveDraftButtonTitle @"Save Draft"
#define kComposeDeleteDraftButtonTitle @"Delete Draft"
#define kComposeCancelButtonTitle @"Cancel"

UIWindow *composeWindow = nil;
UIViewController *keepAliveViewController = nil;
UIView *alertView = nil;
UIPopoverController *popover = nil;
UIButton *showPopoverButton = nil;

UIActionSheet *currentActionSheet = nil;
UIBarButtonItem *currentBarButtonItem = nil;
UIView *currentActionSheetSourceView = nil;

@interface ComposeViewController() <UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageConfirmViewControllerDelegate, SuggestionViewDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, strong) IBOutlet SuggestionView *suggestionView;
@property (nonatomic, strong) IBOutlet UIButton *mentionButton;
@property (nonatomic, strong) IBOutlet UIButton *hashtagButton;
@property (nonatomic, strong) IBOutlet UIButton *pictureButton;
@property (nonatomic, strong) IBOutlet UIButton *showDraftsButton;
@property (nonatomic, strong) IBOutlet ComposeContentView *composeContentView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) SMTEDelegateController *textExpander;
@property (nonatomic) NSRange suggestionReplacementRange;

- (Draft *)createDraftOfCurrentContents;

- (void)reloadCharacterCountLabel;
- (void)registerObservers;
- (void)unregisterObservers;

- (void)dismiss;

- (void)showCommandButtons;
- (void)showSuggestions;

- (void)shareImage:(UIImage *)image;
- (void)applyAlertViewTransformAnimated:(BOOL)animated;

- (IBAction)suggestionButtonTapped:(id)sender;
- (IBAction)mentionButtonTapped:(id)sender;
- (IBAction)hashtagButtonTapped:(id)sender;
- (IBAction)uploadPictureButtonTapped:(id)sender;
- (IBAction)showDraftsButtonTapped:(id)sender;
@end

@implementation ComposeViewController
- (id)init
{
    self = [super initWithNibName:@"ComposeViewController" bundle:nil];
    if(self) {
        self.textExpander = [[SMTEDelegateController alloc] init];
        
        self.navigationItem.title = @"Compose";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        
        [self registerObservers];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)viewDidLoad
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view.opaque = NO;
        self.view.backgroundColor = [UIColor clearColor];
        self.containerView.opaque = NO;
        self.containerView.backgroundColor = [UIColor clearColor];
        
        [self.toolbar setBackgroundImage:[[UIImage imageNamed:@"ipad-compose-toolbar-bottom-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    } else {
        [self.toolbar setBackgroundImage:[[UIImage imageNamed:@"tool-bar-plain-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    self.composeContentView.replyToID = self.replyUserName;
    self.composeContentView.replyToText = self.replyText;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.textView.textColor = [UIColor postBodyTextColor];
    self.textView.backgroundColor = [UIColor postBackgroundColor];
    
    // should check if TextExpander is enabled.
    if([SMTEDelegateController isTextExpanderTouchInstalled]) {
        [self.textView setDelegate:self.textExpander];
        [self.textExpander setNextDelegate:self];
    } else {
        [self.textView setDelegate:self];
    }
    
    if(self.defaultText && (self.textView.text.length == 0)) {
        [self.textView setText:self.defaultText];
    }
    
    [self.textView becomeFirstResponder];
    
    if(self.shouldStartEditingFromBeginning) {
        self.textView.selectedRange = NSMakeRange(0, 0);
    }
    
    if([[[Drafts sharedDrafts] drafts] count] == 0) {
        self.showDraftsButton.hidden = YES;
    } else {
        self.showDraftsButton.hidden = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"textView.text"]) {
        [self reloadCharacterCountLabel];
    } else if([keyPath isEqualToString:@"drafts"]) {
        if(self.suggestionView.hidden == YES) {
            self.showDraftsButton.hidden = [[[Drafts sharedDrafts] drafts] count] == 0;
        }
    } else if([keyPath isEqualToString:@"replyUserName"]) {
        self.composeContentView.replyToID = self.replyUserName;
        self.composeContentView.replyToText = self.replyText;
    }
}

#pragma mark -
#pragma mark Public API
- (void)presentInViewController:(UIViewController *)theViewController
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        [theViewController presentModalViewController:navigationController animated:YES];
    } else {
        composeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        composeWindow.opaque = NO;
        composeWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        composeWindow.windowLevel = UIWindowLevelAlert;
        
        alertView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 380+32, 300+32)];
        alertView.center = CGPointMake(composeWindow.bounds.size.width * 0.5, composeWindow.bounds.size.height * 0.5);
        [composeWindow addSubview:alertView];
        
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:alertView.bounds];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        shadowView.image = [[UIImage imageNamed:@"modal-rounded-shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 22, 22)];
        [alertView addSubview:shadowView];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 380, 300)];
        view.center = CGPointMake(alertView.bounds.size.width * 0.5, alertView.bounds.size.height * 0.5);
        [alertView addSubview:view];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        navigationController.view.frame = view.bounds;
        navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:navigationController.view];
        
        keepAliveViewController = navigationController;
        
        [self applyAlertViewTransformAnimated:NO];
        CGAffineTransform transform = alertView.transform;
        alertView.transform = CGAffineTransformScale(transform, 0.8, 0.8);
        composeWindow.alpha = 0;
        [composeWindow makeKeyAndVisible];
        [UIView animateWithDuration:0.25 animations:^{
            alertView.transform = transform;
            composeWindow.alpha = 1;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

#pragma mark -
#pragma mark Actions
- (IBAction)cancel:(id)sender
{
    NSString *text = self.textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(text.length > 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kComposeCancelButtonTitle destructiveButtonTitle:kComposeDeleteDraftButtonTitle otherButtonTitles:kComposeSaveDraftButtonTitle, nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            currentActionSheet = actionSheet;
            currentBarButtonItem = sender;
            [actionSheet showFromBarButtonItem:sender animated:YES];
        } else {
            [actionSheet showInView:self.view];
        }
    } else {
        [self dismiss];
    }
}

- (IBAction)done:(id)sender
{
    NSString *text = self.textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    Draft *draft = [self createDraftOfCurrentContents];
    
    if(text.length > 0) {
        ActivityNotificationView *notificationView = [[ActivityNotificationView alloc] init];
        [notificationView showInWindow:self.view.window animated:YES];
        
        [APIPostCreate createPostWithText:text replyUserID:self.replyID completionHandler:^(Post *post, NSError *error) {
            notificationView.state = (error == nil) ? ActivityNotificationViewStateAccepted : ActivityNotificationViewStateRejected;
            [notificationView dismissAnimated:YES];
            
            if(post) {
                [[NSNotificationCenter defaultCenter] postNotificationName:APIPostCreateDidFinishNotification object:nil];
            } else {
                [[Drafts sharedDrafts] addDraft:draft];
            }
        }];
    }
    
    [self dismiss];
}

- (IBAction)suggestionButtonTapped:(id)sender
{
    /*if([[self.suggestionButton titleForState:UIControlStateNormal] length] > 0) {
        NSString *originalText = self.textView.text;
        NSRange replacementRange = self.suggestionReplacementRange;
        NSString *replacementText = [NSString stringWithFormat:@"%@ ", [self.suggestionButton titleForState:UIControlStateNormal]];
        NSString *newText = [originalText stringByReplacingCharactersInRange:replacementRange withString:replacementText];
        self.textView.text = newText;
        [self.textView setSelectedRange:NSMakeRange(replacementRange.location + replacementText.length, 0)];
        [self.textView.delegate textViewDidChange:self.textView];
    }*/
}

- (IBAction)mentionButtonTapped:(id)sender
{
    [self.textView insertText:@"@"];
}

- (IBAction)hashtagButtonTapped:(id)sender
{
    [self.textView insertText:@"#"];
}

- (IBAction)uploadPictureButtonTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:kTakePhotoButtonTitle];
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:kChooseExistingButtonTitle];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        currentActionSheet = actionSheet;
        currentActionSheetSourceView = sender;
        [actionSheet showFromRect:[sender bounds] inView:sender animated:YES];
    } else {
        [actionSheet showInView:sender];
    }
}

- (IBAction)showDraftsButtonTapped:(id)sender
{
    DraftsViewController *controller = [[DraftsViewController alloc] init];
    controller.pickedDraftAction = ^ void(Draft *theDraft) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = theDraft.text;
            if(theDraft.replyToID) {
                self.replyID = theDraft.replyToID;
            }
            if(theDraft.replyText) {
                self.replyText = theDraft.replyText;
            }
            
            [popover dismissPopoverAnimated:YES];
            popover = nil;
        });
        
        [[Drafts sharedDrafts] removeDraft:theDraft];
    };
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:navigationController animated:YES];
    } else {
        popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        popover.delegate = self;
        navigationController.contentSizeForViewInPopover = CGSizeMake(320, 400);
        controller.contentSizeForViewInPopover = CGSizeMake(320, 400);
        showPopoverButton = sender;
        [popover presentPopoverFromRect:showPopoverButton.bounds inView:showPopoverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

#pragma mark -
#pragma mark Private API
- (void)registerObservers
{
    [[Drafts sharedDrafts] addObserver:self forKeyPath:@"drafts" options:0 context:0];
    [self addObserver:self forKeyPath:@"textView.text" options:NSKeyValueObservingOptionInitial context:0];
    [self addObserver:self forKeyPath:@"replyUserName" options:0 context:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterObservers
{
    [[Drafts sharedDrafts] removeObserver:self forKeyPath:@"drafts"];
    [self removeObserver:self forKeyPath:@"textView.text"];
    [self removeObserver:self forKeyPath:@"replyUserName"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismiss
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [self.textView resignFirstResponder];
        [UIView animateWithDuration:0.25 animations:^{
            alertView.transform = CGAffineTransformScale(alertView.transform, 0.8, 0.8);
            composeWindow.alpha = 0;
        } completion:^(BOOL finished) {
            composeWindow = nil;
        }];
    }
}

- (Draft *)createDraftOfCurrentContents
{
    Draft *draft = [[Draft alloc] init];
    draft.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    draft.replyToID = self.replyID;
    draft.replyText = self.replyText;
    return draft;
}

- (void)reloadCharacterCountLabel
{
    if([self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 || self.textView.text.length > 256) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    if(self.textView.text.length > 256) {
        self.characterCountLabel.textColor = [UIColor redColor];
    } else {
        self.characterCountLabel.textColor = [UIColor whiteColor];
    }
    self.characterCountLabel.text = [NSString stringWithFormat:@"%i", 256 - self.textView.text.length];
}

- (void)showCommandButtons
{
    [self.suggestionView setHidden:YES];
    [self.mentionButton setHidden:NO];
    [self.hashtagButton setHidden:NO];
    [self.pictureButton setHidden:NO];
    [self.showDraftsButton setHidden:[[[Drafts sharedDrafts] drafts] count] == 0];
}

- (void)showSuggestions
{
    [self.suggestionView setHidden:NO];
    [self.mentionButton setHidden:YES];
    [self.hashtagButton setHidden:YES];
    [self.pictureButton setHidden:YES];
    [self.showDraftsButton setHidden:YES];
}

- (void)shareImage:(UIImage *)image
{
    __block BOOL cancelled = NO;
    UploadingView *uploadingView = [[UploadingView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    
    void (^imageUploadComplete)(NSURL *, BOOL) = ^ (NSURL *url, BOOL succeeded) {
        if(url != nil && cancelled == NO) {
            [self.textView insertText:[[url absoluteString] stringByAppendingString:@" "]];
        }
        
        [uploadingView dismiss];
    };
    
    void (^uploadCancelledCallback)() = ^() {
        cancelled = YES;
    };
    
    uploadingView.uploadingViewDidCancelCallback = uploadCancelledCallback;
    [uploadingView show];
    
    if([[UserSettings sharedUserSettings] photoService] == PhotoServiceSettingYfrog) {
        [[Yfrog sharedYfrog] sendImageToYfrog:image completionCallback:imageUploadComplete];
    } else if([[UserSettings sharedUserSettings] photoService] == PhotoServiceSettingCloudApp) {
        [[CloudApp sharedCloudApp] sendImageToCloudApp:image completionCallback:imageUploadComplete];
    }
}

- (void)applyAlertViewTransformAnimated:(BOOL)animated
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat offset = 0;
    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
        transform = CGAffineTransformIdentity;
        offset = 100;
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        transform = CGAffineTransformMakeRotation(M_PI);
        offset = 100;
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        offset = 150;
    } else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
        transform = CGAffineTransformMakeRotation(M_PI * 1.5);
        offset = 150;
    }
    
    transform = CGAffineTransformTranslate(transform, 0, -offset);
    
    alertView.transform = transform;
}

#pragma mark -
#pragma mark Notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
        
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        CGRect frame = self.view.bounds;
        frame.size.height -= keyboardRect.size.height;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.containerView.frame = frame;
        [UIView commitAnimations];
    } else {
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //self.containerView.frame = self.view.bounds;
        [UIView commitAnimations];
    } else {
        
    }
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification
{
    [self applyAlertViewTransformAnimated:YES];
    
    if(popover) {
        [popover presentPopoverFromRect:showPopoverButton.bounds inView:showPopoverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    if(currentActionSheet) {
        UIActionSheet *clone = [[UIActionSheet alloc] initWithTitle:currentActionSheet.title delegate:currentActionSheet.delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for(NSUInteger i=0; i<currentActionSheet.numberOfButtons; i++) {
            [clone addButtonWithTitle:[currentActionSheet buttonTitleAtIndex:i]];
        }
        
        clone.destructiveButtonIndex = currentActionSheet.destructiveButtonIndex;
        clone.cancelButtonIndex = currentActionSheet.cancelButtonIndex;
        [currentActionSheet dismissWithClickedButtonIndex:currentActionSheet.cancelButtonIndex animated:NO];
        
        currentActionSheet = clone;
        if(currentBarButtonItem) {
            [currentActionSheet showFromBarButtonItem:currentBarButtonItem animated:YES];
        } else if(currentActionSheetSourceView) {
            [currentActionSheet showFromRect:currentActionSheetSourceView.bounds inView:currentActionSheetSourceView animated:YES];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kComposeDeleteDraftButtonTitle]) {
        [self dismiss];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kComposeSaveDraftButtonTitle]) {
        [[Drafts sharedDrafts] addDraft:[self createDraftOfCurrentContents]];
        
        [self dismiss];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kTakePhotoButtonTitle]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.delegate = self;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:controller animated:YES];
        } else {
            popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            popover.delegate = self;
            showPopoverButton = (UIButton *)currentActionSheetSourceView;
            [popover presentPopoverFromRect:showPopoverButton.bounds inView:showPopoverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            [controller.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [controller.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
        }
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kChooseExistingButtonTitle]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:controller animated:YES];
        } else {
            popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            popover.delegate = self;
            showPopoverButton = (UIButton *)currentActionSheetSourceView;
            [popover presentPopoverFromRect:showPopoverButton.bounds inView:showPopoverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            [controller.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [controller.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
        }
    }
    
    currentActionSheet = nil;
    currentActionSheetSourceView = nil;
    currentBarButtonItem = nil;
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self showCommandButtons];
    self.suggestionView.suggestions = nil;
    
    if(textView.selectedRange.length == 0) {
        if(textView.selectedRange.location != NSNotFound) {
            NSMutableString *buffer = [[NSMutableString alloc] initWithString:@""];
            BOOL foundUsername = NO;
            BOOL foundHashtag = NO;
            for(NSInteger i=textView.selectedRange.location - 1; i>= 0; i--) {
                if([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[textView.text characterAtIndex:i]]) {
                    break;
                }
                
                NSString *substring = [textView.text substringWithRange:NSMakeRange(i, 1)];
                [buffer insertString:substring atIndex:0];
            }
            
            if(buffer.length > 0) {
                if([buffer characterAtIndex:0] == '@') {
                    foundUsername = YES;
                } else if([buffer characterAtIndex:0] == '#') {
                    foundHashtag = YES;
                }
                
                if(foundUsername) {
                    NSSet *matchingNames = [[UsernamePool sharedUsernamePool] usernamesMatching:[buffer substringFromIndex:1]];
                    if(matchingNames.count > 0) {
                        [self showSuggestions];
                        self.suggestionView.suggestions = [[[matchingNames allObjects] arrayByMappingBlock:^id(id theElement, NSUInteger theIndex) {
                            return [NSString stringWithFormat:@"@%@", theElement];
                        }] arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
                            return theIndex < 20;
                        }];
                        self.suggestionReplacementRange = NSMakeRange(self.textView.selectedRange.location - buffer.length, buffer.length);
                    }
                } else if(foundHashtag) {
                    NSSet *matchingTags = [[HashtagPool sharedHashtagPool] hashtagsMatching:[buffer substringFromIndex:1]];
                    if(matchingTags.count > 0) {
                        [self showSuggestions];
                        self.suggestionView.suggestions = [[[matchingTags allObjects] arrayByMappingBlock:^id(id theElement, NSUInteger theIndex) {
                            return [NSString stringWithFormat:@"#%@", theElement];
                        }] arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
                            return theIndex < 20;
                        }];
                        self.suggestionReplacementRange = NSMakeRange(self.textView.selectedRange.location - buffer.length, buffer.length);
                    }
                }
            }
        }
    }
    
    [self reloadCharacterCountLabel];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self shareImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [picker dismissModalViewControllerAnimated:YES];
        } else {
            [popover dismissPopoverAnimated:YES];
            popover = nil;
        }
    } else {
        ImageConfirmViewController *controller = [[ImageConfirmViewController alloc] init];
        controller.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        controller.delegate = self;
        [picker pushViewController:controller animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [picker dismissModalViewControllerAnimated:YES];
    } else {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
}

#pragma mark -
#pragma mark ImageConfirmViewControllerDelegate
- (void)imageConfirmViewController:(ImageConfirmViewController *)theController confirmedImage:(UIImage *)image
{
    [self shareImage:image];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [theController dismissModalViewControllerAnimated:YES];
    } else {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
}

- (void)imageConfirmViewControllerCancelled:(ImageConfirmViewController *)theController
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [theController dismissModalViewControllerAnimated:YES];
    } else {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
}

#pragma mark -
#pragma mark SuggestionViewDelegate
- (void)suggestionView:(SuggestionView *)theSuggestionView suggestedValue:(NSString *)theValue
{
    if(theValue.length == 0) {
        return;
    }
    
    NSString *originalText = self.textView.text;
    NSRange replacementRange = self.suggestionReplacementRange;
    NSString *replacementText = [NSString stringWithFormat:@"%@ ", theValue];
    NSString *newText = [originalText stringByReplacingCharactersInRange:replacementRange withString:replacementText];
    self.textView.text = newText;
    [self.textView setSelectedRange:NSMakeRange(replacementRange.location + replacementText.length, 0)];
    [self.textView.delegate textViewDidChange:self.textView];
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)thePopoverController
{
    showPopoverButton = nil;
    popover = nil;
}
@end
