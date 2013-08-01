//
//  APIError.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

extern NSString *APIErrorDomain;

extern NSString *APIErrorCommunicationsErrorDescription;
extern NSString *APIErrorCommunicationsErrorReason;

extern NSString *APIErrorNotAuthenticatedDescription;
extern NSString *APIErrorNotAuthenticatedReason;

enum {
    APIErrorUnknown = 1,
    APIErrorCancelled = 2,
    APIErrorCommunicationsError = 3,
    APIErrorNotAuthenticated = 4,
};
typedef NSInteger APIErrorCode;
