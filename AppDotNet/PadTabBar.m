//
//  PadTabBar.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PadTabBar.h"

@interface PadTabBar()
@property (nonatomic, strong) UIView *dividerLayer;
@property (nonatomic, strong) UIView *selectedItemBackgroundLayer;
@property (nonatomic, strong) UIView *buttonLayer;

@property (nonatomic, copy) NSArray *dividers;
@property (nonatomic, strong) UIImageView *selectedItemBackgroundView;
@property (nonatomic, copy) NSArray *buttons;

- (void)finishInit;
- (void)layoutSelectedItemBackground;
@end

@implementation PadTabBar
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
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    UIImage *image = [UIImage imageNamed:@"ipad-sidebar-bg.png"];
    if([image respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(22, 5, 6, 5) resizingMode:UIImageResizingModeStretch];
    } else {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(22, 0, 6, 0)];
    }
    backgroundView.image = image;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:backgroundView];
    
    UIImageView *noiseView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    noiseView.image = [[UIImage imageNamed:@"generic-noise.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    noiseView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:noiseView];
    
    self.dividerLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    self.dividerLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.dividerLayer];
    
    self.selectedItemBackgroundLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    self.selectedItemBackgroundLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.selectedItemBackgroundLayer];
    
    self.buttonLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, self.bounds.size.height - 44)];
    self.buttonLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.buttonLayer];
    
    [self addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
    [self addObserver:self forKeyPath:@"selectedItem" options:0 context:0];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"items"];
    [self removeObserver:self forKeyPath:@"selectedItem"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        TabBarItem *item = [self.items objectAtIndex:idx];
        
        if(button.frame.size.width > 100) {
            [button setTitle:[NSString stringWithFormat:@"  %@", item.title] forState:UIControlStateNormal];
        } else {
            [button setTitle:nil forState:UIControlStateNormal];
        }
    }];
    
    [self layoutSelectedItemBackground];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"items"]) {
        for(UIButton *button in self.buttons) {
            [button removeFromSuperview];
        }
        
        for(UIImageView *divider in self.dividers) {
            [divider removeFromSuperview];
        }
        
        self.buttons = nil;
        self.dividers = nil;
        
        CGFloat buttonHeight = 75;
        __block CGFloat top = 0;
        self.buttons = [self.items arrayByMappingBlock:^id(id theElement, NSUInteger theIndex) {
            TabBarItem *item = theElement;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, top, self.bounds.size.width, buttonHeight);
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [button setTitle:[NSString stringWithFormat:@"   %@", item.title] forState:UIControlStateNormal];
            [button setImage:item.image forState:UIControlStateNormal];
            [button setImage:item.selectedImage forState:UIControlStateSelected];
            [button setImage:item.selectedImage forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchDown];
            [button setTitleColor:[UIColor colorWithRed:151.0 / 255.0 green:158.0 / 255.0 blue:168.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [button setAdjustsImageWhenHighlighted:NO];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [self.buttonLayer addSubview:button];
            
            top += buttonHeight;
            return button;
        }];
        
        top = buttonHeight - 2;
        self.dividers = [self.items arrayByMappingBlock:^id(id theElement, NSUInteger theIndex) {
            UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(0, top, self.bounds.size.width, 3)];
            
            UIImage *image = [UIImage imageNamed:@"ipad-ls-sidebar-divider.png"];
            if([image respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
                image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5) resizingMode:UIImageResizingModeStretch];
            }
            
            divider.image = image;
            divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:divider];
            [self.dividerLayer addSubview:divider];
            
            top += buttonHeight;
            return divider;
        }];
        
        [self layoutSelectedItemBackground];
    } else if([keyPath isEqualToString:@"selectedItem"]) {
        [self layoutSelectedItemBackground];
    }
}

#pragma mark -
#pragma mark Actions
- (void)tabButtonPressed:(id)sender
{
    self.selectedItem = [self.items objectAtIndex:[self.buttons indexOfObject:sender]];
}

#pragma mark -
#pragma mark Private API
- (void)layoutSelectedItemBackground
{
    if(!self.selectedItemBackgroundView) {
        self.selectedItemBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        self.selectedItemBackgroundView.image = [UIImage imageNamed:@"ipad-sidebar-btn-pressed.png"];
        [self.selectedItemBackgroundLayer addSubview:self.selectedItemBackgroundView];
    }
    
    NSUInteger indexOfSelectedItem = NSNotFound;
    if(self.selectedItem) {
        indexOfSelectedItem = [self.items indexOfObject:self.selectedItem];
    }
    
    if(indexOfSelectedItem == NSNotFound) {
        self.selectedItemBackgroundView.hidden = YES;
    }
    self.selectedItemBackgroundView.hidden = NO;
    
    self.selectedItemBackgroundView.frame = CGRectMake(0, (75.0f * indexOfSelectedItem) - 1.0f, self.bounds.size.width, 76);
    
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        TabBarItem *item = [self.items objectAtIndex:idx];
        if(idx == indexOfSelectedItem) {
            [button setImage:item.selectedImage forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [button setSelected:YES];
        } else {
            [button setImage:item.image forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:151.0 / 255.0 green:158.0 / 255.0 blue:168.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
            
            [button setSelected:NO];
        }
    }];
}
@end
