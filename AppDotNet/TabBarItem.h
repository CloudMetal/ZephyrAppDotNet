//
//  TabBarItem.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface TabBarItem : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) BOOL showsNewPostIndicator;
@property (nonatomic) BOOL hasNewPosts;
@end
