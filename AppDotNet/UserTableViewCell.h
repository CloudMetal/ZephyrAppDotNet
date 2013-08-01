//
//  UserTableViewCell.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserTableViewCell : UITableViewCell
@property (nonatomic, strong) User *user;
@end
