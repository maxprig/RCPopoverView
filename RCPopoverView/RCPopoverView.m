//
//  RCPopoverView.m
//  TakeOrder
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import "RCPopoverView.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 0.3f

@interface RCPopoverView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, assign) RCPopoverViewStyle style;
@property (nonatomic, assign) CGRect originFrame;

@end

@implementation RCPopoverView

#pragma mark - Class Methods

+ (RCPopoverView *)sharedView
{
    static dispatch_once_t once;
    static RCPopoverView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[RCPopoverView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)showWithView:(UIView *)popover
{
    [[RCPopoverView sharedView] showWithView:popover];
}

+ (void)showWithView:(UIView *)view completion:(CompletionBlock)completion
{
    
}

+ (void)showWithView:(UIView *)view completion:(CompletionBlock)completion style:(RCPopoverViewStyle)style
{
    
}

+ (void)dismiss
{
    [[RCPopoverView sharedView] dismiss];
}

+ (BOOL)isVisible {
    return ([RCPopoverView sharedView].alpha == 1);
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0f;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = YES;
        self.tapDismissEnabled = NO;
        self.slideDismissEnabled = NO;
    }
    return self;
}

- (void)showWithView:(UIView *)view
{
    if (self.hudView)
    {
        [self.hudView removeFromSuperview];
        self.hudView = nil;
    }
    self.hudView = view;
    self.originFrame = self.hudView.frame;
    [self addSubview:self.hudView];
    
    if (self.slideDismissEnabled) {
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.hudView addGestureRecognizer:recognizer];
    }
    
    if (self.tapDismissEnabled) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tapGesture];
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:swipeGesture];
    }
    
    if ([RCPopoverView isVisible]) {
        [RCPopoverView dismiss];
        return;
    }
    
    if (!self.superview) {
        [self.overlayWindow addSubview:self];
    }
    [self.overlayWindow setHidden:NO];
    
    if(self.alpha != 1) {
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3f, 1.3f);
        [UIView animateWithDuration:kAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.alpha = 1;
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.0f / 1.3f, 1.0f / 1.3f);
                         }
                         completion:^(BOOL finished){
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                         }];
    }
    [self setNeedsDisplay];
}


- (void)dismiss
{
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8f, 0.8f);
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3 animations:^{
                             self.alpha = 0;
                         } completion:^(BOOL finished) {
                             [self.hudView removeFromSuperview];
                             _hudView = nil;
                             
                             [self.overlayWindow removeFromSuperview];
                             _overlayWindow = nil;
                             
                             // fixes bug where keyboard wouldn't return as keyWindow upon dismissal of HUD
                             [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id window, NSUInteger idx, BOOL *stop) {
                                 if ([window isMemberOfClass:[UIWindow class]])
                                 {
                                     [window makeKeyWindow];
                                     *stop = YES;
                                 }
                             }];
                             
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                             
                             if (self.completion)
                             {
                                 self.completion();
                             }
                         }];
                     }];
}

#pragma mark - Helper Methods

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = self.hudView.frame;
        if (frame.origin.x > self.frame.size.width/3) {
            [self dismiss];
        } else {
            //animate back to origin
            [UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hudView setFrame:self.originFrame];
            } completion:nil];
        }
    }
}

- (UIWindow *)overlayWindow
{
    if (!_overlayWindow)
    {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.windowLevel = UIWindowLevelStatusBar;
        _overlayWindow.userInteractionEnabled = YES;
    }
    return _overlayWindow;
}

@end
