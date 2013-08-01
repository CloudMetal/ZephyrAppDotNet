//
//  LoadMoreTableViewCell.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "LoadMoreTableViewCell.h"

@interface LoadMoreTableViewCell()
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *loadMoreButton;
@end

@implementation LoadMoreTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundView.image = [UIImage imageNamed:@"load-more-posts-bg.png"];
        [self addSubview:self.backgroundView];
        
        self.loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.loadMoreButton setAdjustsImageWhenHighlighted:NO];
        [self.loadMoreButton setImage:[UIImage imageNamed:@"load-more-posts-button.png"] forState:UIControlStateNormal];
        [self.loadMoreButton setImage:[UIImage imageNamed:@"load-more-posts-button-pressed.png"] forState:UIControlStateHighlighted];
        self.loadMoreButton.frame = self.bounds;
        [self.loadMoreButton addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loadMoreButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.loadMoreButton.frame = self.bounds;
    
    /*CGFloat cellHeight = self.bounds.size.height;
    CGFloat buttonSize = cellHeight - self.buttonView.image.size.height;
    self.buttonView.frame = CGRectMake(roundf((self.bounds.size.width - buttonSize) / 2), 2, buttonSize, buttonSize);*/
}

#pragma mark -
#pragma mark Actions
- (void)loadMore:(id)sender
{
    [self.delegate loadMoreTableViewCellTapped:self];
}
@end
