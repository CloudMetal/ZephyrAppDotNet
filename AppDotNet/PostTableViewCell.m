//
//  PostTableViewCell.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PostTableViewCell.h"
#import "PostTableViewCellMenu.h"
#import "AvatarPool.h"
#import "LinkZone.h"

CGFloat PostTableViewCellGetAvatarSize() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 64;
    } else {
        return 50;
    }
}

CGFloat PostTableViewCellGetLeftContentInset() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return PostTableViewCellGetAvatarSize() + 40;
    } else {
        return PostTableViewCellGetAvatarSize() + 20;
    }
}

CGFloat PostTableViewCellGetTopContentInset() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 40;
    } else {
        return 30;
    }
}

CGFloat PostTableViewCellGetRightContentInset() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 25;
    } else {
        return 10;
    }
}

CGFloat PostTableViewCellGetBottomContentInset() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 20;
    } else {
        return 10;
    }
}

CGFloat PostTableViewCellGetAnnotatedBottomContentInset() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 40;
    } else {
        return 30;
    }
}

CGFloat PostTableViewCellGetMinimumHeight() {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return PostTableViewCellGetAvatarSize() + 41 - 10;
    } else {
        return PostTableViewCellGetAvatarSize() + 21;
    }
}

NSString *PostTableViewCellSwipedRightNotification = @"PostTableViewCellSwipedRightNotification";

@interface PostTableViewCell() <PostTableViewCellMenuDelegate>
@property (nonatomic, strong) PostTableViewCellMenu *menuView;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) LinkZone *tappedLinkZone;
@property (nonatomic) BOOL pressed;

@property (nonatomic, strong) NSTimer *longPressTimer;

- (void)refreshAfterTimeInterval:(NSTimeInterval)interval;
@end

@implementation PostTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.contentMode = UIViewContentModeTop;
        self.clipsToBounds = YES;
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        [self addObserver:self forKeyPath:@"isAuthenticatedUser" options:0 context:0];
        [self addObserver:self forKeyPath:@"isThread" options:0 context:0];
        [self addObserver:self forKeyPath:@"tappedLinkZone" options:0 context:0];
        [self addObserver:self forKeyPath:@"youStarred" options:0 context:0];
        [self addObserver:self forKeyPath:@"expanded" options:0 context:0];
        [self addObserver:self forKeyPath:@"hasMentions" options:0 context:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarPoolFinishedDownload:) name:AvatarPoolFinishedDownloadNotification object:[AvatarPool sharedAvatarPool]];
        
        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeGestureRecognizer];
        
        swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeGestureRecognizer];
        
        self.menuView = [[PostTableViewCellMenu alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kPostTableViewCellMenuHeight)];
        self.menuView.delegate = self;
        [self addSubview:self.menuView];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isAuthenticatedUser"];
    [self removeObserver:self forKeyPath:@"isThread"];
    [self removeObserver:self forKeyPath:@"tappedLinkZone"];
    [self removeObserver:self forKeyPath:@"youStarred"];
    [self removeObserver:self forKeyPath:@"expanded"];
    [self removeObserver:self forKeyPath:@"hasMentions"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AvatarPoolFinishedDownloadNotification object:[AvatarPool sharedAvatarPool]];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    if(self.expanded) {
        self.menuView.frame = CGRectMake(0, self.bounds.size.height - kPostTableViewCellMenuHeight, self.bounds.size.width, kPostTableViewCellMenuHeight);
    } else {
        self.menuView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, kPostTableViewCellMenuHeight);
    }
}

- (void)prepareForReuse
{
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    self.avatarImage = nil;
    self.tappedLinkZone = nil;
    self.isAuthenticatedUser = NO;
    self.expanded = NO;
    self.youStarred = NO;
    self.pressed = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"tappedLinkZone"]) {
        [self setNeedsDisplay];
    } else if([keyPath isEqualToString:@"isAuthenticatedUser"]) {
        self.menuView.isMenuForUserPost = self.isAuthenticatedUser;
    } else if([keyPath isEqualToString:@"isThread"]) {
        self.menuView.isMenuForThreadPost = self.isThread;
    } else if([keyPath isEqualToString:@"youStarred"]) {
        self.menuView.isMenuForStarredPost = self.youStarred;
    } else if([keyPath isEqualToString:@"expanded"]) {
        if(self.expanded) {
            //[self.menuView makeAnEntrance];
        }
    } else if([keyPath isEqualToString:@"hasMentions"]) {
        self.menuView.shouldReplyAllBeAvailable = self.hasMentions;
    }
}

- (NSString *)dateString
{
    if(!self.creationDate) {
        return @"";
    }
    
    NSInteger interval = abs([self.creationDate timeIntervalSinceNow]);
    
    NSUInteger seconds = interval;
    NSUInteger minutes = interval / 60;
    NSUInteger hours = interval / 3600;
    
    if(seconds == 0) {
        [self refreshAfterTimeInterval:1];
        return @"now";
    } else if(seconds < 60) {
        [self refreshAfterTimeInterval:1];
        return [NSString stringWithFormat:@"%us", seconds];
    } else if(minutes < 60) {
        [self refreshAfterTimeInterval:60];
        return [NSString stringWithFormat:@"%um", minutes];
    } else if(hours < 24) {
        [self refreshAfterTimeInterval:60];
        return [NSString stringWithFormat:@"%uhr", hours];
    }
    
    NSDateFormatter *formatter = [[[NSThread currentThread] threadDictionary] objectForKey:@"com.enderlabs.celldateformatter"];
    if(formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [[[NSThread currentThread] threadDictionary] setObject:formatter forKey:@"com.enderlabs.celldateformatter"];
    }
    
    return [formatter stringFromDate:self.creationDate];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect cellContentRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    if(self.expanded) {
        cellContentRect.size.height -= kPostTableViewCellMenuHeight;
    }
    
    // Background
    if(self.mentionsAuthenticatedUser) {
        //[[UIColor colorWithRed:0.75 green:0.85 blue:0.95 alpha:1.0] set];
        [[UIColor colorWithRed:0.85 green:0.92 blue:0.98 alpha:1.0] set];
    } else {
        [[UIColor postBackgroundColor] set];
    }
    
    if(self.pressed) {
        //[[UIColor postHighlightedBackgroundColor] set];
    }
    
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    // Avatar
    if(!self.avatarImage && self.avatarURL) {
        self.avatarImage = [[AvatarPool sharedAvatarPool] avatarImageForURL:self.avatarURL];
    }
    
    CGContextSaveGState(context);
    CGFloat avatarTop = PostTableViewCellGetTopContentInset() - 20;
    CGFloat avatarLeft = PostTableViewCellGetLeftContentInset() - PostTableViewCellGetAvatarSize() - 10;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        avatarTop -= 5;
        avatarLeft -= 5;
    }
    
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(avatarLeft, avatarTop, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize()) cornerRadius:5] addClip];
    if(self.avatarImage) {
        [self.avatarImage drawInRect:CGRectMake(avatarLeft, avatarTop, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize())];
    } else {
        static UIImage *placeholder = nil;
        if(!placeholder) {
            placeholder = [UIImage imageNamed:@"avatar-placeholder.png"];
        }
        
        [placeholder drawInRect:CGRectMake(avatarLeft, avatarTop, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize())];
    }
    CGContextRestoreGState(context);
    
    [[UIColor whiteColor] set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(avatarLeft - 0.5, avatarTop - 0.5, PostTableViewCellGetAvatarSize() + 1, PostTableViewCellGetAvatarSize() + 1) cornerRadius:5] stroke];
    
    // Post date
    CGFloat topLabelsTop = PostTableViewCellGetTopContentInset() - 20;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        topLabelsTop -= 5;
    }
    
    CGRect topLabelsRect = CGRectMake(PostTableViewCellGetLeftContentInset(), topLabelsTop, self.bounds.size.width - (PostTableViewCellGetLeftContentInset() + PostTableViewCellGetRightContentInset()), 20);
    CGRect topLabelsShadowRect = CGRectMake(topLabelsRect.origin.x, topLabelsRect.origin.y + 1, topLabelsRect.size.width, topLabelsRect.size.height);
    CGFloat infoFontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 15 : 14;
    UIFont *boldInfoFont = [UIFont boldSystemFontOfSize:infoFontSize];
    UIFont *infoFont = [UIFont systemFontOfSize:infoFontSize];
    
    NSString *dateString = [self dateString];
    CGSize dateStringSize = [dateString sizeWithFont:boldInfoFont];
    
    if(self.mentionsAuthenticatedUser) {
        [[UIColor postHighlightedTopStrokeColor] set];
    } else {
        [[UIColor postShadowTextColor] set];
    }
    [dateString drawInRect:topLabelsShadowRect withFont:boldInfoFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
    
    if(self.mentionsAuthenticatedUser) {
        [[UIColor postHighlightedMetaTextColor] set];
    } else {
        [[UIColor postMetaTextColor] set];
    }
    [dateString drawInRect:topLabelsRect withFont:boldInfoFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
    
    // Via/Repost
    CGRect bottomLabelsRect = CGRectMake(PostTableViewCellGetLeftContentInset(), cellContentRect.size.height - (PostTableViewCellGetBottomContentInset() - 5), cellContentRect.size.width - (PostTableViewCellGetLeftContentInset() + PostTableViewCellGetRightContentInset()), 20);
    bottomLabelsRect.origin.y -= (PostTableViewCellGetAnnotatedBottomContentInset() - PostTableViewCellGetBottomContentInset());
    
    CGRect bottomLabelsShadowRect = CGRectMake(bottomLabelsRect.origin.x, bottomLabelsRect.origin.y + 1, bottomLabelsRect.size.width, bottomLabelsRect.size.height);
    
    //CGFloat bottomRightLabelsLeft = bottomLabelsRect.origin.x + bottomLabelsRect.size.width;
    
    if(self.repostedByUserName) {
        CGSize nameSize = [self.repostedByUserName sizeWithFont:boldInfoFont];
        
        if(self.mentionsAuthenticatedUser) {
            [[UIColor postHighlightedTopStrokeColor] set];
        } else {
            [[UIColor postShadowTextColor] set];
        }
        [self.repostedByUserName drawInRect:bottomLabelsShadowRect withFont:boldInfoFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
        
        if(self.mentionsAuthenticatedUser) {
            [[UIColor postHighlightedMetaTextColor] set];
        } else {
            [[UIColor postMetaTextColor] set];
        }
        [self.repostedByUserName drawInRect:bottomLabelsRect withFont:boldInfoFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
        
        bottomLabelsRect.origin.x -= nameSize.width;
        bottomLabelsShadowRect.origin.x -= nameSize.width;
        //bottomRightLabelsLeft -= nameSize.width;
        
        if(self.mentionsAuthenticatedUser) {
            [[UIColor postHighlightedTopStrokeColor] set];
        } else {
            [[UIColor postShadowTextColor] set];
        }
        [@"reposted by " drawInRect:bottomLabelsShadowRect withFont:infoFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
        
        if(self.mentionsAuthenticatedUser) {
            [[UIColor postHighlightedMetaTextColor] set];
        } else {
            [[UIColor postMetaTextColor] set];
        }
        [@"reposted by " drawInRect:bottomLabelsRect withFont:infoFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
        
        //bottomRightLabelsLeft -= [@"reposted by " sizeWithFont:infoFont].width;
    } else {
        /*NSString *viaString = [NSString stringWithFormat:@"via %@", self.via];
        
        [[UIColor postShadowTextColor] set];
        [viaString drawInRect:bottomLabelsShadowRect withFont:infoFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
        
        [[UIColor postMetaTextColor] set];
        [viaString drawInRect:bottomLabelsRect withFont:infoFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
        
        bottomRightLabelsLeft -= [viaString sizeWithFont:infoFont].width;*/
    }
    
    if(self.youStarred) {
        [[UIImage imageNamed:@"post-icon-star.png"] drawAtPoint:CGPointMake(10, bottomLabelsRect.origin.y + 3)];
    }
    
    // User name
    [[UIColor postUserNameColor] set];
    [self.userName drawInRect:CGRectMake(topLabelsRect.origin.x, topLabelsRect.origin.y, topLabelsRect.size.width - (dateStringSize.width + 10), topLabelsRect.size.height) withFont:boldInfoFont lineBreakMode:UILineBreakModeTailTruncation];
    
    // Content
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, cellContentRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layout drawInContext:context];
    CGContextRestoreGState(context);
    
    // Tapped Link Zones
    if(self.tappedLinkZone) {
        [[UIColor colorWithWhite:0 alpha:0.25] set];
        UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
        for(NSValue *rectValue in self.tappedLinkZone.rects) {
            CGRect rect = CGRectInset(rectValue.CGRectValue, -3, -3);
            [bezierPath appendPath:[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5]];
        }
        [bezierPath fill];
    }
    
    // Top Line
    if(self.mentionsAuthenticatedUser) {
        [[UIColor postHighlightedTopStrokeColor] set];
    } else {
        [[UIColor postTopStrokeColor] set];
    }
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, cellContentRect.size.width, 1)] fill];
    
    // Bottom line
    if(self.mentionsAuthenticatedUser) {
        [[UIColor postHighlightedBottomStrokeColor] set];
    } else {
        [[UIColor postBottomStrokeColor] set];
    }
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, cellContentRect.size.height - 1, cellContentRect.size.width, 1)] fill];
}

#pragma mark -
#pragma mark Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    self.tappedLinkZone = nil;
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(longPress:) userInfo:nil repeats:NO];
    
    // Tight search
    for(LinkZone *linkZone in self.linkZones) {
        for(NSValue *rectValue in linkZone.rects) {
            CGRect rect = rectValue.CGRectValue;
            if(CGRectContainsPoint(rect, location)) {
                self.tappedLinkZone = linkZone;
                return;
            }
        }
    }
    
    // Expanded search
    for(LinkZone *linkZone in self.linkZones) {
        for(NSValue *rectValue in linkZone.rects) {
            CGRect rect = CGRectInset(rectValue.CGRectValue, -10, -10);
            if(CGRectContainsPoint(rect, location)) {
                self.tappedLinkZone = linkZone;
                return;
            }
        }
    }
    
    self.pressed = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pressed = NO;
    
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
    
    if(self.tappedLinkZone) {
        [self.delegate tableViewCell:self tappedLinkZone:self.tappedLinkZone];
    } else {
        [self.delegate tableViewCellTapped:self];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.1];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tappedLinkZone = nil;
        });
    });
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pressed = NO;
    
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
    
    self.tappedLinkZone = nil;
}

#pragma mark -
#pragma mark Actions
- (IBAction)swipeRight:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PostTableViewCellSwipedRightNotification object:self];
}

- (IBAction)swipe:(id)sender
{
    [self.delegate tableViewCellSwiped:self];
}

- (void)longPress:(NSTimer *)theTimer
{
    self.longPressTimer = nil;
    
    if(self.tappedLinkZone) {
        if([self.delegate tableViewCell:self longPressedLinkZone:self.tappedLinkZone]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:0.1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tappedLinkZone = nil;
                });
            });
        }
    }
}

#pragma mark -
#pragma mark Private API
- (void)refreshAfterTimeInterval:(NSTimeInterval)interval
{
    if(self.refreshTimer) {
        return;
    }
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(refresh:) userInfo:nil repeats:NO];
}

- (void)refresh:(NSTimer *)timer
{
    self.refreshTimer = nil;
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Public API
- (void)makeAnEntrance
{
    [self.menuView makeAnEntrance];
}

#pragma mark -
#pragma mark Notifications
-(void)avatarPoolFinishedDownload:(NSNotification *)notification
{
    if(!self.avatarImage) {
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark PostTableViewCellMenuDelegate
- (void)postTableViewCellMenuChoseReply:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedReply:self];
}

- (void)postTableViewCellMenuChoseRepost:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedRepost:self];
}

- (void)postTableViewCellMenuChoseNativeRepost:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedNativeRepost:self];
}

- (void)postTableViewCellMenuChoseDelete:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedDelete:self];
}

- (void)postTableViewCellMenuChoseCopy:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedCopy:self];
}

- (void)postTableViewCellMenuChoseCopyURLOfPost:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedCopyURLOfPost:self];
}

- (void)postTableViewCellMenuChoseReplyAll:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedReplyAll:self];
}

- (void)postTableViewCellMenuChoseViewThread:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellSwiped:self];
}

- (void)postTableViewCellMenuChoseViewProfile:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedViewProfile:self];
}

- (void)postTableViewCellMenuChoseMailPost:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedMailPost:self];
}

- (void)postTableViewCellMenuChoseStar:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedStar:self];
}

- (void)postTableViewCellMenuChoseUnstar:(PostTableViewCellMenu *)thePostTableViewCellMenu
{
    [self.delegate tableViewCellPickedUnstar:self];
}
@end
