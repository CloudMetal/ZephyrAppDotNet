//
//  APIUpdateStreamMarker.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "APIUpdateStreamMarker.h"

@implementation APIUpdateStreamMarker
+ (void)updateStreamMarkerWithName:(NSString *)theStreamName postID:(NSString *)thePostID percentage:(CGFloat)thePercentage
{
    if(!theStreamName || theStreamName.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Stream name must not be nil and must be non-zero length"];
    }
    
    if(!thePostID || thePostID.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Post ID must not be nil and must be non-zero length"];
    }
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:theStreamName forKey:@"name"];
    [postData setObject:thePostID forKey:@"id"];
    [postData setObject:[NSNumber numberWithInt:thePercentage * 100] forKey:@"percentage"];
    
    APIUpdateStreamMarker *api = [[APIUpdateStreamMarker alloc] init];
    api.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/marker"]];
    api.bodyData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:0];
    api.HTTPHeaderFields = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"content-type"];
    api.method = VDownloadMethodPOST;
    api.callType = APICallTypeStreamMarker;
    
    [api call];
}
@end
