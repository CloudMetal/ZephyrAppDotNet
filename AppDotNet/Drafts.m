//
//  Drafts.m
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import "Drafts.h"

@interface Drafts()
@property (nonatomic, copy) NSArray *drafts;

- (void)loadDrafts;
- (void)saveDrafts;
@end

@implementation Drafts
- (NSString *)dataFilePath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [path stringByAppendingPathComponent:@"drafts.dat"];
}

+ (Drafts *)sharedDrafts
{
    static Drafts *instance = nil;
    if(instance == nil) {
        instance = [[Drafts alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if(self) {
        [self loadDrafts];
        
        [self addObserver:self forKeyPath:@"drafts" options:0 context:0];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"drafts"]) {
        [self saveDrafts];
    }
}

- (void)addDraft:(Draft *)draft
{
    self.drafts = [@[draft] arrayByAddingObjectsFromArray:self.drafts];
}

- (void)removeDraft:(Draft *)draft
{
    self.drafts = [self.drafts arrayByFilteringUsingBlock:^BOOL(id theElement, NSUInteger theIndex) {
        return theElement != draft;
    }];
}

- (void)loadDrafts
{
    self.drafts = [[NSArray alloc] init];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        NSArray *newDrafts = [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePath]];
        
        if(newDrafts) {
            self.drafts = newDrafts;
        }
    }
}

- (void)saveDrafts
{
    [NSKeyedArchiver archiveRootObject:self.drafts toFile:[self dataFilePath]];
}
@end
