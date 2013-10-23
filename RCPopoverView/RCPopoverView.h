//
//  RCPopoverView.h
//  RCPopoverView
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    RCPopoverViewStyleFromTop,
    RCPopoverViewStyleExpandFade
} RCPopoverViewStyle;

typedef void (^CompletionBlock)(void);

@interface RCPopoverView : UIView

@property (nonatomic, copy) CompletionBlock completion;

// Configurable properties
@property (nonatomic, assign) BOOL tapDismissEnabled;
@property (nonatomic, assign) BOOL slideDismissEnabled;

// Getters
+ (RCPopoverView *)sharedView;
+ (BOOL)isVisible;

// Public Methods
+ (void)showWithView:(UIView *)popover;
+ (void)showWithView:(UIView *)view completion:(CompletionBlock)completion;
+ (void)showWithView:(UIView *)view completion:(CompletionBlock)completion style:(RCPopoverViewStyle)style;

+ (void)dismiss;

@end
