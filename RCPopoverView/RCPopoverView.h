//
//  RCPopoverView.h
//  RCPopoverView
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    RCPopoverViewAnimationStyleExpandFade,
    RCPopoverViewAnimationtyleFromBottom
} RCPopoverViewAnimationStyle;

typedef void (^RCCompletionBlockVoid)(void);

@interface RCPopoverView : UIView

@property (nonatomic, copy) RCCompletionBlockVoid completion;

// Configurable properties
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL tapToDismissEnabled;
@property (nonatomic, assign) BOOL slideToDismissEnabled;

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

// Getters
+ (RCPopoverView *)sharedView;
+ (BOOL)isVisible;

// Public Methods
+ (void)showWithView:(UIView *)view;
+ (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style;
+ (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style completion:(RCCompletionBlockVoid)completion;
+ (void)dismiss;

@end
