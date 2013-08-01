//
//  Draft.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface Draft : NSObject
@property (nonatomic, copy) NSString *replyToID;
@property (nonatomic, copy) NSString *replyText;
@property (nonatomic, copy) NSString *text;
@end
