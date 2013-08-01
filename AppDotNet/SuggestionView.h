//
//  SuggestionView.h
//  AppDotNet
//
//  Copyright 2012-2013 Ender Labs. All rights reserved.
//  Created by Donald Hays.
//

#import <Foundation/Foundation.h>

@class SuggestionView;

@protocol SuggestionViewDelegate <NSObject>
- (void)suggestionView:(SuggestionView *)theSuggestionView suggestedValue:(NSString *)theValue;
@end

@interface SuggestionView : UIView
@property (nonatomic, weak) IBOutlet id<SuggestionViewDelegate> delegate;

@property (nonatomic, copy) NSArray *suggestions;
@end
