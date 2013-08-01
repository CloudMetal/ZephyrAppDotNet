//
//  PostTableViewCellMenu.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostTableViewCellMenu.h"
#import <MessageUI/MessageUI.h>

#define kReplyButtonTitle @"Reply"
#define kReplyAllButtonTitle @"Reply to All"
#define kViewThreadButtonTitle @"View Thread"
#define kViewProfileButtonTitle @"View Profile"
#define kMailPostButtonTitle @"Mail Post"
#define kCopyPostButtonTitle @"Copy Post"
#define kCopyURLOfPostButtonTitle @"Copy URL of Post"
#define kRepostToFollowersButtonTitle @"Repost to Followers"
#define kQuotePostButtonTitle @"Quote Post"

@interface PostTableViewCellMenu() <UIActionSheetDelegate>
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIActionSheet *currentActionSheet;
@property (nonatomic, strong) UIView *actionSheetParentView;

@property (nonatomic, strong) UIButton *buttonA;
@property (nonatomic, strong) UIButton *buttonB;
@property (nonatomic, strong) UIButton *buttonC;
@property (nonatomic, strong) UIButton *buttonD;

- (void)setTitle:(NSString *)theTitle forButton:(UIButton *)theButton;
@end

@implementation PostTableViewCellMenu
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"action-view-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
        self.backgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, kPostTableViewCellMenuHeight);
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.backgroundView];
        
        self.buttonA = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonB = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonC = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonD = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.buttonA.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [self.buttonB.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [self.buttonC.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [self.buttonD.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        
        [self.buttonA setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonB setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonC setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.buttonD setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.buttonA.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.buttonB.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.buttonC.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.buttonD.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        
        [self.buttonA setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.buttonB setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.buttonC setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.buttonD setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        
        [self addSubview:self.buttonA];
        [self addSubview:self.buttonB];
        [self addSubview:self.buttonC];
        [self addSubview:self.buttonD];
        
        [self.buttonA setImage:[UIImage imageNamed:@"action-button-reply.png"] forState:UIControlStateNormal];
        [self.buttonB setImage:[UIImage imageNamed:@"action-button-repost.png"] forState:UIControlStateNormal];
        [self.buttonC setImage:[UIImage imageNamed:@"action-button-star.png"] forState:UIControlStateNormal];
        [self.buttonD setImage:[UIImage imageNamed:@"action-button-share.png"] forState:UIControlStateNormal];
        
        [self.buttonA addTarget:self action:@selector(buttonATapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonB addTarget:self action:@selector(buttonBTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonC addTarget:self action:@selector(buttonCTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonD addTarget:self action:@selector(buttonDTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setTitle:@"Reply" forButton:self.buttonA];
        [self setTitle:@"Repost" forButton:self.buttonB];
        [self setTitle:@"Star" forButton:self.buttonC];
        [self setTitle:@"Actions" forButton:self.buttonD];
        
        [self addObserver:self forKeyPath:@"isMenuForUserPost" options:0 context:0];
        [self addObserver:self forKeyPath:@"isMenuForStarredPost" options:0 context:0];
        
        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
        splitView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        splitView.backgroundColor = [UIColor whiteColor];
        splitView.alpha = 0.025;
        [self addSubview:splitView];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isMenuForUserPost"];
    [self removeObserver:self forKeyPath:@"isMenuForStarredPost"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"isMenuForUserPost"]) {
        if(self.isMenuForUserPost) {
            [self setTitle:@"Delete" forButton:self.buttonB];
            [self.buttonB setImage:[UIImage imageNamed:@"action-button-trash.png"] forState:UIControlStateNormal];
        } else {
            [self setTitle:@"Repost" forButton:self.buttonB];
            [self.buttonB setImage:[UIImage imageNamed:@"action-button-repost.png"] forState:UIControlStateNormal];
        }
    } else if([keyPath isEqualToString:@"isMenuForStarredPost"]) {
        if(self.isMenuForStarredPost) {
            [self setTitle:@"Unstar" forButton:self.buttonC];
            [self.buttonC setImage:[UIImage imageNamed:@"action-button-star-empty.png"] forState:UIControlStateNormal];
        } else {
            [self setTitle:@"Star" forButton:self.buttonC];
            [self.buttonC setImage:[UIImage imageNamed:@"action-button-star.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)layoutSubviews
{
    CGRect layoutRect = CGRectMake(10, 3, self.bounds.size.width - 20, self.bounds.size.height - 6);
    
    CGFloat buttonWidth = floorf((layoutRect.size.width - 30) / 4);
    CGFloat buttonPadding = 10;
    
    CGFloat left = layoutRect.origin.x;
    
    self.buttonA.frame = CGRectMake(left, layoutRect.origin.y, buttonWidth, layoutRect.size.height);
    left = self.buttonA.frame.origin.x + self.buttonA.frame.size.width + buttonPadding;
    
    self.buttonB.frame = CGRectMake(left, layoutRect.origin.y, buttonWidth, layoutRect.size.height);
    left = self.buttonB.frame.origin.x + self.buttonB.frame.size.width + buttonPadding;
    
    self.buttonC.frame = CGRectMake(left, layoutRect.origin.y, buttonWidth, layoutRect.size.height);
    left = self.buttonC.frame.origin.x + self.buttonC.frame.size.width + buttonPadding;
    
    self.buttonD.frame = CGRectMake(left, layoutRect.origin.y, buttonWidth, layoutRect.size.height);
    
    if(self.currentActionSheet) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActionSheet *newActionSheet = [[UIActionSheet alloc] initWithTitle:self.currentActionSheet.title delegate:self.currentActionSheet.delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for(NSUInteger i=0; i<self.currentActionSheet.numberOfButtons; i++) {
                [newActionSheet addButtonWithTitle:[self.currentActionSheet buttonTitleAtIndex:i]];
            }
            
            newActionSheet.cancelButtonIndex = self.currentActionSheet.cancelButtonIndex;
            
            [self.currentActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
            
            self.currentActionSheet = newActionSheet;
            [self.currentActionSheet showFromRect:self.actionSheetParentView.bounds inView:self.actionSheetParentView animated:NO];
        });
    }
}

#pragma mark -
#pragma mark Private API
- (void)setTitle:(NSString *)theTitle forButton:(UIButton *)theButton
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [theButton setTitle:[NSString stringWithFormat:@"  %@", theTitle] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark Actions
- (void)buttonATapped:(id)sender
{
    if(self.shouldReplyAllBeAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        [actionSheet addButtonWithTitle:kReplyButtonTitle];
        [actionSheet addButtonWithTitle:kReplyAllButtonTitle];
        
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.currentActionSheet = actionSheet;
            self.actionSheetParentView = self.buttonA;
            [actionSheet showFromRect:self.buttonA.bounds inView:self.buttonA animated:YES];
        } else {
            [actionSheet showInView:self];
        }
    } else {
        [self.delegate postTableViewCellMenuChoseReply:self];
    }
}

- (void)buttonBTapped:(id)sender
{
    if(self.isMenuForUserPost) {
        [self.delegate postTableViewCellMenuChoseDelete:self];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        [actionSheet addButtonWithTitle:kRepostToFollowersButtonTitle];
        [actionSheet addButtonWithTitle:kQuotePostButtonTitle];
        
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.currentActionSheet = actionSheet;
            self.actionSheetParentView = self.buttonB;
            [actionSheet showFromRect:self.buttonB.bounds inView:self.buttonB animated:YES];
        } else {
            [actionSheet showInView:self];
        }
    }
}

- (void)buttonCTapped:(id)sender
{
    if(self.isMenuForStarredPost) {
        [self.delegate postTableViewCellMenuChoseUnstar:self];
    } else {
        [self.delegate postTableViewCellMenuChoseStar:self];
    }
}

- (void)buttonDTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if(!self.isMenuForThreadPost) {
        [actionSheet addButtonWithTitle:kViewThreadButtonTitle];
    }
    
    [actionSheet addButtonWithTitle:kViewProfileButtonTitle];
    
    if([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:kMailPostButtonTitle];
    }
    
    [actionSheet addButtonWithTitle:kCopyPostButtonTitle];
    [actionSheet addButtonWithTitle:kCopyURLOfPostButtonTitle];
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.currentActionSheet = actionSheet;
        self.actionSheetParentView = self.buttonD;
        [actionSheet showFromRect:self.buttonD.bounds inView:self.buttonD animated:YES];
    } else {
        [actionSheet showInView:self];
    }
}

#pragma mark -
#pragma mark Public API
- (void)makeAnEntrance
{
    __block CGFloat delay = 0;
    NSArray *buttons = @[self.buttonA, self.buttonB, self.buttonC, self.buttonD];
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        
        button.transform = CGAffineTransformMakeScale(0.5, 0.5);
        button.alpha = 0;
        
        [UIView animateWithDuration:0.2 delay:delay options:0 animations:^{
            button.transform = CGAffineTransformMakeScale(1.2, 1.2);
            button.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                button.transform = CGAffineTransformIdentity;
            }];
        }];
        
        delay += 0.066;
    }];
}

#pragma mark -
#pragma mark Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.currentActionSheet = nil;
    self.actionSheetParentView = nil;
    
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:kReplyButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseReply:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:kReplyAllButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseReplyAll:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kViewThreadButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseViewThread:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kViewProfileButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseViewProfile:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kMailPostButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseMailPost:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kCopyPostButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseCopy:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kCopyURLOfPostButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseCopyURLOfPost:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRepostToFollowersButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseNativeRepost:self];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kQuotePostButtonTitle]) {
        [self.delegate postTableViewCellMenuChoseRepost:self];
    }
}
@end
