//
//  TabBarViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "TabBarViewController.h"
#import "TabBar.h"
#import "MoreViewController.h"

@interface TabBarViewController()
@property (nonatomic, copy) NSArray *internalViewControllers;
@property (nonatomic, strong) UINavigationController *moreNavigationController;

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet TabBar *tabBar;
@property (nonatomic, strong) UIButton *hideTabBarButton;

- (UIScrollView *)grabScrollViewFromSubviewsOfView:(UIView *)theView scrollViewCount:(NSUInteger *)theScrollViewCount;
@end

@implementation TabBarViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self addObserver:self forKeyPath:@"selectedViewController" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"viewControllers" options:0 context:0];
        [self addObserver:self forKeyPath:@"internalViewControllers" options:0 context:0];
        [self addObserver:self forKeyPath:@"tabBar" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"tabBar.selectedItem" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"tabBar.showingMore" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedViewController"];
    [self removeObserver:self forKeyPath:@"viewControllers"];
    [self removeObserver:self forKeyPath:@"internalViewControllers"];
    [self removeObserver:self forKeyPath:@"tabBar"];
    [self removeObserver:self forKeyPath:@"tabBar.selectedItem"];
    [self removeObserver:self forKeyPath:@"tabBar.showingMore"];
}

- (void)viewDidLoad
{
    for(UIViewController *viewController in self.viewControllers) {
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
    
    self.selectedViewController = [self.viewControllers objectAtIndex:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"selectedViewController"]) {
        if(![[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]]) {
            while(self.contentView.subviews.count > 0) {
                [[self.contentView.subviews lastObject] removeFromSuperview];
            }
            
            if(self.selectedViewController) {
                self.selectedViewController.view.frame = self.contentView.bounds;
                self.selectedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.contentView addSubview:self.selectedViewController.view];
            }
            
            if(self.tabBar.selectedItem != self.selectedViewController.adnTabBarItem) {
                self.tabBar.selectedItem = self.selectedViewController.adnTabBarItem;
            }
        }
    } else if([keyPath isEqualToString:@"viewControllers"] || [keyPath isEqualToString:@"tabBar"]) {
        if(![[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]]) {
            if(self.viewControllers.count > 5) {
                NSMutableArray *internal = [[NSMutableArray alloc] init];
                for(NSUInteger i=0; i<4; i++) {
                    [internal addObject:[self.viewControllers objectAtIndex:i]];
                }
                
                MoreViewController *more = [[MoreViewController alloc] init];
                self.moreNavigationController = [[UINavigationController alloc] initWithRootViewController:more];
                self.moreNavigationController.adnTabBarItem.image = [UIImage imageNamed:@"tab-icon-more.png"];
                self.moreNavigationController.adnTabBarItem.selectedImage = [UIImage imageNamed:@"tab-icon-more-pressed.png"];
                
                NSArray *moreControllers = [self.viewControllers arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
                    return theIndex >= 4;
                }];
                more.viewControllers = moreControllers;
                [internal addObject:self.moreNavigationController];
                
                self.internalViewControllers = internal;
                
                if(![self.internalViewControllers containsObject:self.selectedViewController]) {
                    if(self.selectedViewController) {
                        // Hack hack hack, this just jumps to settings.
                        [more pushLastViewController];
                        self.selectedViewController = self.moreNavigationController;
                    }
                }
            } else {
                UIViewController *newViewController = nil;
                if(self.selectedViewController == self.moreNavigationController && self.selectedViewController != nil) {
                    newViewController = [self.moreNavigationController topViewController];
                }
                
                [self.moreNavigationController popToRootViewControllerAnimated:NO];
                self.moreNavigationController = nil;
                
                self.internalViewControllers = self.viewControllers;
                
                if(newViewController) {
                    self.selectedViewController = [self.viewControllers lastObject];
                }
            }
        }
    } else if([keyPath isEqualToString:@"internalViewControllers"]) {
        NSArray *items = [self.internalViewControllers arrayByMappingBlock:^ id (id theElement, NSUInteger theIndex) {
            UIViewController *viewController = theElement;
            return viewController.adnTabBarItem;
        }];
        
        self.tabBar.items = items;
    } else if([keyPath isEqualToString:@"tabBar.selectedItem"]) {
        if(![[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]]) {
            for(UIViewController *controller in self.internalViewControllers) {
                if(controller.adnTabBarItem == self.tabBar.selectedItem) {
                    self.selectedViewController = controller;
                    break;
                }
            }
        } else {
            for(UIViewController *controller in self.internalViewControllers) {
                if(controller.adnTabBarItem == self.tabBar.selectedItem) {
                    if([controller isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *navigationController = (UINavigationController *)controller;
                        if(navigationController.viewControllers.count > 1) {
                            [navigationController popToRootViewControllerAnimated:YES];
                        } else {
                            NSUInteger count = 0;
                            UIScrollView *scrollView = [self grabScrollViewFromSubviewsOfView:navigationController.view scrollViewCount:&count];
                            if(count == 1) {
                                [scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                            }
                        }
                    }
                    break;
                }
            }
        }
    } else if([keyPath isEqualToString:@"tabBar.showingMore"]) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
        [self.hideTabBarButton removeFromSuperview];
        self.hideTabBarButton = nil;
        
        if(self.tabBar.showingMore) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.contentView.transform = CGAffineTransformMakeTranslation(0, -45);
            } completion:^(BOOL finished) {
                
            }];
            
            self.hideTabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.hideTabBarButton.frame = self.contentView.bounds;
            [self.hideTabBarButton addTarget:self action:@selector(hideTabBar:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.hideTabBarButton];
        }
    }
}

- (void)hideTabBar:(id)sender
{
    [self.tabBar showLess];
}

- (UIScrollView *)grabScrollViewFromSubviewsOfView:(UIView *)theView scrollViewCount:(NSUInteger *)theScrollViewCount
{
    UIScrollView *grabbedView = nil;
    
    for(UIView *view in theView.subviews) {
        if([view isKindOfClass:[UIScrollView class]]) {
            grabbedView = (UIScrollView *)view;
            if(theScrollViewCount) {
                (*theScrollViewCount)++;
            }
        } else {
            UIScrollView *candidateView = [self grabScrollViewFromSubviewsOfView:view scrollViewCount:theScrollViewCount];
            if(candidateView) {
                grabbedView = candidateView;
            }
        }
    }
    
    return grabbedView;
}
@end
