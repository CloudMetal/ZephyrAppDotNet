//
//  Drafts.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>
#import "Draft.h"

@interface Drafts : NSObject
@property (nonatomic, readonly, copy) NSArray *drafts;

+ (Drafts *)sharedDrafts;
- (void)addDraft:(Draft *)draft;
- (void)removeDraft:(Draft *)draft;
@end
