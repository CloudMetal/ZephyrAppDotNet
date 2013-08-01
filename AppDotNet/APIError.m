//
//  APIError.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIError.h"

NSString *APIErrorDomain = @"com.enderlabs.ADN.ErrorDomain";

NSString *APIErrorCommunicationsErrorDescription = @"Communication with the App.net server could not be established.";
NSString *APIErrorCommunicationsErrorReason = @"The App.net server may be down, or the device may not have an internet connection.";

NSString *APIErrorNotAuthenticatedDescription = @"The app is not authenticated.";
NSString *APIErrorNotAuthenticatedReason = @"You must authorize the app with App.net in order to use it.";
