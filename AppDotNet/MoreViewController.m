//
//  MoreViewController.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "MoreViewController.h"

@interface MoreViewController()
@property (nonatomic, copy) NSArray *extractedViewControllers;
@end

@implementation MoreViewController
- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        self.title = @"More";
        
        [self addObserver:self forKeyPath:@"viewControllers" options:0 context:0];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"viewControllers"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"viewControllers"]) {
        self.extractedViewControllers = [self.viewControllers arrayByMappingBlock:^id(id theElement, NSUInteger theIndex) {
            if([theElement isKindOfClass:[UINavigationController class]]) {
                if([[theElement viewControllers] count] > 0) {
                    return [[theElement viewControllers] objectAtIndex:0];
                } else {
                    return theElement;
                }
            } else {
                return theElement;
            }
        }];
    }
}

- (void)pushLastViewController
{
    [self.navigationController pushViewController:[self.extractedViewControllers lastObject] animated:NO];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.extractedViewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    UIViewController *viewController = [self.extractedViewControllers objectAtIndex:indexPath.row];
    cell.textLabel.text = viewController.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [self.extractedViewControllers objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
