//
//  UserListMetadata.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface UserListMetadata : NSObject
@property (nonatomic, copy) NSString *maxID;
@property (nonatomic, copy) NSString *minID;
@property (nonatomic) BOOL hasMore;

+ (UserListMetadata *)userListMetadataFromJSONRepresentation:(NSDictionary *)representation;
@end
