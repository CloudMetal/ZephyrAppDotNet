//
//  Keys.h
//  AppDotNet
//
//  Created by Donald Hays on 7/31/13.
//  Copyright (c) 2013 Ender Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

// This is a mandatory key. You won't be able to sign into Zephyr without it.
// You can get one by creating an app for yourself on app.net
#define KeyADNClientID nil

// Get an API key from getpocket.com
// This key is required to share to Pocket, but not for any other feature
#define KeyPocketAPIKey nil

// Get an API key from yfrog.com
// This key is required to share to yfrog, but not for any other feature
#define KeyYfrogAPIKey nil

// Get a TestFlight Team Token from testflightapp.com.
// This is not mandatory for any feature of the app
#define KeyTestFlightTeamToken nil

// Fiber App is an Ender Labs-internal push notification service.
// It's not available externally, so if you want to enable push notifications,
// you'll have to replace our push code in the app with your own.
// Sucks, I know, sorry :(
#define KeyFiberAppServiceKey nil
#define KeyFiberAppSignatureKey nil
