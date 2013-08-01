//
//  APIUserParameters.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@interface APIUserParameters : NSObject
@property (nonatomic, copy) NSString *sinceID;
@property (nonatomic, copy) NSString *beforeID;
@property (nonatomic) NSUInteger countOfUsers;

@property (nonatomic, readonly) NSDictionary *parameterDictionary;
@end
