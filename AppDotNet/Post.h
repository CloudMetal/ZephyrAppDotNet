//
//  Post.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "PostSource.h"
#import "Entities.h"

@interface Post : NSObject
@property (nonatomic, copy) NSString *postID;
@property (nonatomic, strong) User *user;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, strong) PostSource *postSource;
@property (nonatomic, copy) NSString *replyTo;
@property (nonatomic, copy) NSString *threadID;
@property (nonatomic) NSUInteger countOfReplies;
@property (nonatomic, copy) NSDictionary *annotations;
@property (nonatomic, strong) Entities *entities;
@property (nonatomic) BOOL isDeleted;
@property (nonatomic) BOOL youReposted;
@property (nonatomic) BOOL youStarred;
@property (nonatomic, strong) Post *repostOf;

+ (Post *)postFromJSONRepresentation:(NSDictionary *)representation;
@end
