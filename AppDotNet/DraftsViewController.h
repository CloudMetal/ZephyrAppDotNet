//
//  DraftsViewController.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "Draft.h"

@interface DraftsViewController : UITableViewController
@property (nonatomic, copy) void (^ pickedDraftAction)(Draft *theDraft);
@end
