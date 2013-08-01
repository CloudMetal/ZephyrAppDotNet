//
//  TabBar.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "TabBar.h"

#define kNumberOfVisibleTabBarItems 5

@interface TabBar()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *strokeLayerView;
@property (nonatomic, strong) UIView *selectedTabLayerView;
@property (nonatomic, strong) UIView *buttonLayerView;

@property (nonatomic, strong) UIImageView *topStrokeImageView;

@property (nonatomic, strong) UIImageView *selectedTabBackgroundImageView;

@property (nonatomic, copy) NSArray *buttons;
@property (nonatomic, copy) NSArray *splits;
@property (nonatomic, copy) NSArray *indicatorViewsForNewPosts;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) BOOL showingMore;
@property (nonatomic) BOOL shouldIgnoreNextMoreTouchUp;

- (void)finishInit;
- (void)showMore;
@end

@implementation TabBar
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self finishInit];
    }
    return self;
}

- (void)finishInit
{
    self.backgroundColor = [UIColor blackColor];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 45)];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundImageView.image = [UIImage imageNamed:@"tab-bar-background.png"];
    [self addSubview:self.backgroundImageView];
    
    self.strokeLayerView = [[UIView alloc] initWithFrame:self.bounds];
    self.strokeLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.strokeLayerView];
    
    self.selectedTabLayerView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedTabLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.selectedTabLayerView];
    
    self.buttonLayerView = [[UIView alloc] initWithFrame:self.bounds];
    self.buttonLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.buttonLayerView];
    
    self.selectedTabBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 45)];
    self.selectedTabBackgroundImageView.image = [UIImage imageNamed:@"tab-bar-bg-pressed-short.png"];
    [self.selectedTabLayerView addSubview:self.selectedTabBackgroundImageView];
    
    /*self.topStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 2)];
    self.topStrokeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.topStrokeImageView.image = [UIImage imageNamed:@"tab-bar-top-stroke.png"];
    [self.strokeLayerView addSubview:self.topStrokeImageView];*/
    
    [self addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
    [self addObserver:self forKeyPath:@"selectedItem" options:0 context:0];
}

- (void)dealloc
{
    for(TabBarItem *item in self.items) {
        [item removeObserver:self forKeyPath:@"hasNewPosts"];
    }
    
    [self removeObserver:self forKeyPath:@"items"];
    [self removeObserver:self forKeyPath:@"selectedItem"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"items"]) {
        if([change objectForKey:NSKeyValueChangeOldKey] != [NSNull null]) {
            for(TabBarItem *item in [change objectForKey:NSKeyValueChangeOldKey]) {
                [item removeObserver:self forKeyPath:@"hasNewPosts"];
            }
        }
        
        for(TabBarItem *item in self.items) {
            [item addObserver:self forKeyPath:@"hasNewPosts" options:0 context:0];
        }
        
        [self.moreButton removeFromSuperview];
        self.moreButton = nil;
        
        for(UIButton *button in self.buttons) {
            [button removeFromSuperview];
        }
        self.buttons = nil;
        
        for(UIView *split in self.splits) {
            [split removeFromSuperview];
        }
        self.splits = nil;
        
        for(NSDictionary *indicatorDictionary in self.indicatorViewsForNewPosts) {
            [[indicatorDictionary objectForKey:@"view"] removeFromSuperview];
            [[indicatorDictionary objectForKey:@"background"] removeFromSuperview];
        }
        self.indicatorViewsForNewPosts = nil;
        
        if(self.items.count == 0) {
            return;
        }
        
        NSMutableArray *newButtons = [[NSMutableArray alloc] init];
        NSMutableArray *newSplits = [[NSMutableArray alloc] init];
        NSMutableArray *newIndicatorViews = [[NSMutableArray alloc] init];
        CGFloat buttonWidth = self.bounds.size.width / MIN(self.items.count, kNumberOfVisibleTabBarItems);
        
        CGFloat left = 0;
        CGFloat top = 0;
        NSInteger buttonCount = 0;
        for(TabBarItem *item in self.items) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:item.image forState:UIControlStateNormal];
            button.frame = CGRectMake(left, top, buttonWidth, self.bounds.size.height);
            button.adjustsImageWhenHighlighted = NO;
            [button setTag:[self.items indexOfObject:item]];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(buttonTappedUp:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(buttonTappedEnd:) forControlEvents:UIControlEventTouchCancel];
            [button addTarget:self action:@selector(buttonTappedEnd:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(buttonTappedEnd:) forControlEvents:UIControlEventTouchUpOutside];
            [self.buttonLayerView addSubview:button];
            left += buttonWidth;
            [newButtons addObject:button];
            
            if(top == 0 && (left < 320 || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                UIImageView *splitView = [[UIImageView alloc] initWithFrame:CGRectMake(left - 1, 1, 2, 42)];
                splitView.image = [UIImage imageNamed:@"tab-bar-cell-divider.png"];
                [newSplits addObject:splitView];
                [self.strokeLayerView addSubview:splitView];
                
                if(item.showsNewPostIndicator) {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:button.frame];
                    imageView.contentMode = UIViewContentModeBottom;
                    imageView.image = [UIImage imageNamed:@"tab-bar-tray.png"];
                    [self.buttonLayerView addSubview:imageView];
                    
                    UIImageView *lightView = [[UIImageView alloc] initWithFrame:button.frame];
                    lightView.contentMode = UIViewContentModeBottom;
                    lightView.image = [UIImage imageNamed:@"tab-bar-light.png"];
                    [self.buttonLayerView addSubview:lightView];
                    
                    if(item.hasNewPosts == NO) {
                        lightView.alpha = 0;
                    }
                    
                    [newIndicatorViews addObject:@{
                         @"item" : item,
                         @"background" : imageView,
                         @"view" : lightView
                     }];
                }
            }
            
            buttonCount++;
            if((buttonCount == kNumberOfVisibleTabBarItems - 1) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.items.count > 5) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                
                [button setImage:[UIImage imageNamed:@"tab-icon-more.png"] forState:UIControlStateNormal];
                button.frame = CGRectMake(left, top, buttonWidth, self.bounds.size.height);
                button.adjustsImageWhenHighlighted = NO;
                [button setTag:[self.items indexOfObject:item]];
                //[button addTarget:self action:@selector(moreTapped:) forControlEvents:UIControlEventTouchDown];
                [button addTarget:self action:@selector(moreTappedUp:) forControlEvents:UIControlEventTouchUpInside];
                [button addTarget:self action:@selector(moreTappedEnd:) forControlEvents:UIControlEventTouchCancel];
                [button addTarget:self action:@selector(moreTappedEnd:) forControlEvents:UIControlEventTouchUpOutside];
                [button setBackgroundImage:[UIImage imageNamed:@"tab-bar-bg-pressed-short.png"] forState:UIControlStateHighlighted];
                self.moreButton = button;
                [self.buttonLayerView addSubview:button];
                left = 0;
                top += self.bounds.size.height;
            }
        }
        
        self.buttons = newButtons;
        self.splits = newSplits;
        self.indicatorViewsForNewPosts = newIndicatorViews;
    } else if([keyPath isEqualToString:@"selectedItem"]) {
        self.selectedTabBackgroundImageView.hidden = YES;
        
        for(NSUInteger i=0; i<self.items.count; i++) {
            TabBarItem *item = [self.items objectAtIndex:i];
            UIButton *button = [self.buttons objectAtIndex:i];
            
            if(item == self.selectedItem && item.selectedImage != nil) {
                [button setImage:item.selectedImage forState:UIControlStateNormal];
            } else {
                [button setImage:item.image forState:UIControlStateNormal];
            }
        }
        
        if(self.selectedItem) {
            NSUInteger indexOfSelectedItem = [self.items indexOfObject:self.selectedItem];
            UIButton *buttonOfSelectedItem = [self.buttons objectAtIndex:indexOfSelectedItem];
            
            CGRect selectionFrame = buttonOfSelectedItem.frame;
            self.selectedTabBackgroundImageView.hidden = NO;
            self.selectedTabBackgroundImageView.frame = selectionFrame;
        }
    } else if([keyPath isEqualToString:@"hasNewPosts"]) {
        for(TabBarItem *item in self.items) {
            for(NSDictionary *data in self.indicatorViewsForNewPosts) {
                if([data objectForKey:@"item"] == item) {
                    UIImageView *view = [data objectForKey:@"view"];
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        view.alpha = item.hasNewPosts ? 1 : 0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Actions
- (void)buttonTapped:(id)sender
{
    if(!self.showingMore) {
        self.selectedItem = [self.items objectAtIndex:[sender tag]];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"tab-bar-bg-pressed-short.png"] forState:UIControlStateHighlighted];
    }
}

- (void)buttonTappedUp:(id)sender
{
    if(self.showingMore) {
        self.selectedItem = [self.items objectAtIndex:[sender tag]];
        [self showLess];
    }
}

- (void)buttonTappedEnd:(id)sender
{
    [sender setBackgroundImage:nil forState:UIControlStateHighlighted];
}

- (void)moreTapped:(id)sender
{
}

- (void)moreTappedUp:(id)sender
{
    if(self.shouldIgnoreNextMoreTouchUp) {
        self.shouldIgnoreNextMoreTouchUp = NO;
        return;
    }
    
    if(!self.showingMore) {
        //self.shouldIgnoreNextMoreTouchUp = YES;
        [self showMore];
        return;
    }
    
    if(self.showingMore) {
        [self showLess];
    }
}

- (void)moreTappedEnd:(id)sender
{
    //self.shouldIgnoreNextMoreTouchUp = NO;
}

#pragma mark -
#pragma mark Private API
- (void)showMore
{
    if(self.showingMore) {
        return;
    }
    
    self.showingMore = YES;
    self.originalFrame = self.frame;
    [self.moreButton setBackgroundImage:[UIImage imageNamed:@"tab-bar-bg-pressed-short.png"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, self.originalFrame.origin.y - 45, self.originalFrame.size.width, 90);
    }];
}

- (void)showLess
{
    if(!self.showingMore) {
        return;
    }
    
    self.showingMore = NO;
    [self.moreButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = self.originalFrame;
    }];
}
@end
