//
//  RCPopoverView.h
//  RCPopoverView
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCPopoverView : UIView

/** top inset height */
@property (nonatomic, assign) CGFloat inset_top;

/** left inset width */
@property (nonatomic, assign) CGFloat inset_left;

/** UIView to display when activated */
@property (nonatomic, strong) UIView *popoverView;

/**
 *  Activate the popover and show the view
 */
+(void)show;

/**
 *  Activate the popover and show a custom view
 */
+(void)showWithView:(UIView *)popover;

/**
 *  Dismiss the popover programatically
 */
+(void)dismiss;

/**
 *  @return Boolean indicating if the popover is in view
 */
+(BOOL)isVisible;

@end