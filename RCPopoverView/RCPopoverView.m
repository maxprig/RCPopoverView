//
//  RCPopoverView.m
//  TakeOrder
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import "RCPopoverView.h"
#import <QuartzCore/QuartzCore.h>

@interface RCPopoverView() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) RCPopoverViewAnimationStyle style;
@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIView *popoverView;
@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, assign) UIOffset offsetFromCenter;
@property (nonatomic, assign) CGRect originFrame;

@end

@implementation RCPopoverView

#pragma mark - Class Methods

+ (RCPopoverView *)sharedView
{
    static dispatch_once_t once;
    static RCPopoverView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

#pragma mark - Class Methods

+ (void)showWithView:(UIView *)view
{
    [[self sharedView] showWithView:view style:RCPopoverViewAnimationStyleExpandFade completion:nil];
}

+ (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style
{
    [[self sharedView] showWithView:view style:style completion:nil];
}

+ (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style completion:(CompletionBlock)completion
{
    [[self sharedView] showWithView:view style:style completion:completion];
}

+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}

+ (void)dismiss
{
    if ([self isVisible]) {
        [[self sharedView] dismiss];
    }
}

+ (BOOL)isVisible
{
    return ([self sharedView].alpha == 1);
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tapToDismissEnabled = YES;
        self.slideToDismissEnabled = NO;
        self.offsetFromCenter = UIOffsetZero;
        self.animationDuration = 0.2f;
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGFloat freeHeight = self.bounds.size.height - self.visibleKeyboardHeight;
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, freeHeight/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

- (void)updatePosition
{
    self.popoverView.center = CGPointMake(self.overlayView.center.x + self.offsetFromCenter.horizontal, self.overlayView.center.y + self.offsetFromCenter.vertical);
    self.originFrame = self.popoverView.frame;
}

- (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style completion:(CompletionBlock)completion
{
    if ([RCPopoverView isVisible]) {
        [self dismiss];
        return;
    }
    
    if (!self.overlayView.superview) {
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows)
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
    }
    
    if (!self.superview)
        [self.overlayView addSubview:self];
    
    if (self.popoverView) {
        [self.popoverView removeFromSuperview];
        _popoverView = nil;
    }
    self.popoverView = view;
    [self updatePosition];
    [self addSubview:self.popoverView];
    
    if (self.slideToDismissEnabled) {
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.popoverView addGestureRecognizer:recognizer];
    }
    
    if (self.tapToDismissEnabled) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tapGesture];
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:swipeGesture];
    }
    
    self.overlayView.userInteractionEnabled = YES;
    [self.overlayView setHidden:NO];
    
    self.style = style;
    self.completion = completion;
    
    if (self.alpha != 1) {
        if (style == RCPopoverViewAnimationStyleExpandFade) {
            self.popoverView.transform = CGAffineTransformScale(self.popoverView.transform, 1.3f, 1.3f);
        }
        if (style == RCPopoverViewAnimationtyleFromBottom) {
            CGRect frame = self.popoverView.frame;
            frame.origin.y += 50.0f;
            self.popoverView.frame = frame;
        }
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             switch (style) {
                                 case RCPopoverViewAnimationStyleExpandFade:
                                 {
                                     self.popoverView.transform = CGAffineTransformScale(self.popoverView.transform, 1.0f / 1.3f, 1.0f / 1.3f);
                                 }
                                     break;
                                 case RCPopoverViewAnimationtyleFromBottom:
                                 {
                                     CGRect frame = self.popoverView.frame;
                                     frame.origin.y -= 50.0f;
                                     self.popoverView.frame = frame;
                                 }
                                     break;
                                 default:
                                     break;
                             }
                             self.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                         }];
    }
    [self setNeedsDisplay];
}


- (void)dismiss
{
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0f
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         switch (self.style) {
                             case RCPopoverViewAnimationStyleExpandFade:
                             {
                                 self.popoverView.transform = CGAffineTransformScale(self.popoverView.transform, 0.8f, 0.8f);
                             }
                                 break;
                             case RCPopoverViewAnimationtyleFromBottom:
                             {
                                 CGRect frame = self.popoverView.frame;
                                 frame.origin.y += 50.0f;
                                 self.popoverView.frame = frame;
                             }
                                 break;
                                 
                             default:
                                 break;
                         }
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self.popoverView removeFromSuperview];
                         _popoverView = nil;
                         
                         [self.overlayView removeFromSuperview];
                         _overlayView = nil;
                         
                         UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                         
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
                         // Tell the rootViewController to update the StatusBar appearance
                         UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                         if ([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                             [rootController setNeedsStatusBarAppearanceUpdate];
                         }
#endif
                         
                         if (self.completion)
                         {
                             self.completion();
                         }
                     }];
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = self.popoverView.frame;
        if (frame.origin.x > self.frame.size.width/2) {
            [self dismiss];
        } else {
            //animate back to origin
            [UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.popoverView setFrame:self.originFrame];
            } completion:nil];
        }
    }
}

#pragma mark - Setters

- (void)setOffsetFromCenter:(UIOffset)offsetFromCenter
{
    _offsetFromCenter = offsetFromCenter;
    [self updatePosition];
}

#pragma mark - Getters

- (UIControl *)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
    }
    return _overlayView;
}

@end
