//
//  UsernamePool.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "UsernamePool.h"

@interface UsernamePool()
@property (nonatomic, strong) NSMutableSet *pool;
@end

@implementation UsernamePool
+ (UsernamePool *)sharedUsernamePool
{
    static UsernamePool *sharedUsernamePoolInstance = nil;
    if(!sharedUsernamePoolInstance) {
        sharedUsernamePoolInstance = [[UsernamePool alloc] init];
    }
    return sharedUsernamePoolInstance;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.pool = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addUsername:(NSString *)theUsername name:(NSString *)theName
{
    @synchronized(self) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    theUsername, @"username",
                                    theName, @"name",
                                    nil];
        
        [self.pool addObject:dictionary];
    }
}

- (NSSet *)usernamesMatching:(NSString *)theString
{
    NSSet *set = nil;
    @synchronized(self) {
        set = [self.pool filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"username beginswith[c] %@", theString]];
        
        if(set.count == 0) {
            set = [self.pool filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"(username contains[c] %@) OR (name contains[c] %@)", theString, theString]];
        }
        
        NSMutableSet *workingSet = [NSMutableSet set];
        [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            NSDictionary *dictionary = obj;
            [workingSet addObject:[dictionary objectForKey:@"username"]];
        }];
        set = workingSet;
    }
    return set;
}
@end
