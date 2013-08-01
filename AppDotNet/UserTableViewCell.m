//
//  UserTableViewCell.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UserTableViewCell.h"
#import "AvatarPool.h"
#import "PostTableViewCell.h"

@interface  UserTableViewCell()
@property (nonatomic, strong) UIImage *avatar;
@end

@implementation UserTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self addObserver:self forKeyPath:@"user" options:0 context:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarLoaded:) name:AvatarPoolFinishedDownloadNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"user"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AvatarPoolFinishedDownloadNotification object:nil];
}

- (void)avatarLoaded:(NSNotification *)notification
{
    if(!self.avatar) {
        [self setNeedsDisplay];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"user"]) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] set];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    self.avatar = [[AvatarPool sharedAvatarPool] avatarImageForURL:self.user.avatarImage.url];
    if(!self.avatar) {
        [[UIImage imageNamed:@"avatar-placeholder.png"] drawInRect:CGRectMake(10, 10, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize())];
    } else {
        [self.avatar drawInRect:CGRectMake(10, 10, PostTableViewCellGetAvatarSize(), PostTableViewCellGetAvatarSize())];
    }
    
    [[UIColor blackColor] set];
    [self.user.name drawInRect:CGRectMake(84, 10, self.bounds.size.width - 84, 30) withFont:[UIFont boldSystemFontOfSize:15]];
    
    [[UIColor grayColor] set];
    [[NSString stringWithFormat:@"@%@", self.user.userName] drawInRect:CGRectMake(84, 30, self.bounds.size.width - 84, 30) withFont:[UIFont systemFontOfSize:15]];
    
    NSString *followString = @"";
    
    if(self.user.youFollow) {
        followString = @"You follow";
    }
    
    if(self.user.followsYou) {
        if(followString.length > 0) {
            followString = [followString stringByAppendingString:@", follows you"];
        } else {
            followString = @"Follows you";
        }
    }
    
    [followString drawInRect:CGRectMake(84, 50, self.bounds.size.width - 84, 30) withFont:[UIFont systemFontOfSize:15]];
}
@end
