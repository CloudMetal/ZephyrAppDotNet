//
//  PadTabBarViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "PadTabBarViewController.h"
#import "PadTabBar.h"

@interface PadTabBarViewController()
@property (nonatomic, copy) NSArray *internalViewControllers;

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet PadTabBar *tabBar;

- (UIScrollView *)grabScrollViewFromSubviewsOfView:(UIView *)theView scrollViewCount:(NSUInteger *)theScrollViewCount;
@end

@implementation PadTabBarViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self addObserver:self forKeyPath:@"selectedViewController" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"viewControllers" options:0 context:0];
        [self addObserver:self forKeyPath:@"internalViewControllers" options:0 context:0];
        [self addObserver:self forKeyPath:@"tabBar" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
        [self addObserver:self forKeyPath:@"tabBar.selectedItem" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
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
}

- (void)viewDidLoad
{
    for(UIViewController *viewController in self.viewControllers) {
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
    
    self.selectedViewController = [self.viewControllers objectAtIndex:0];
}

- (void)viewDidLayoutSubviews
{
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.tabBar.frame = CGRectMake(0, 0, 154 - 1, self.view.bounds.size.height);
        self.contentView.frame = CGRectMake(154, 0, self.view.bounds.size.width - 154, self.view.bounds.size.height);
    } else {
        self.tabBar.frame = CGRectMake(0, 0, 64 - 1, self.view.bounds.size.height);
        self.contentView.frame = CGRectMake(64, 0, self.view.bounds.size.width - 64, self.view.bounds.size.height);
    }
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
            self.internalViewControllers = self.viewControllers;
            self.selectedViewController = [self.internalViewControllers objectAtIndex:0];
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
    }
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
