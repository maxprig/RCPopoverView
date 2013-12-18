# RCPopoverView

RCPopoverView is an easy to use cocoa class that can display a generic or custom UIView with fade and slide animations.

![RCPopoverView](http://i.imgur.com/YXecPvS.png)

## Installation

### Use CocoaPods

- Add `pod 'RCPopoverView'` to your Podfile

## Usage

Show the popover

```objective-c
+ (void)showWithView:(UIView *)view;

// use custom animation style
+ (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style;

// using a completion handler
+ (void)showWithView:(UIView *)view style:(RCPopoverViewAnimationStyle)style completion:(CompletionBlock)completion;
```

Dismiss the view

```objective-c
+ (void)dismiss;
```

## Features

Change the animation duration

```objective-c
[RCPopoverView sharedView].animationDuration = 0.5;
```

Disable tap to dismiss

```objective-c
[RCPopoverView sharedView].tapToDismissEnabled = NO;
```

Enable slide to dismiss (slide to the right to dismiss the view)

```objective-c
[RCPopoverView sharedView].slideToDismissEnabled = YES;
```

Animation Styles (More to come!)

```objective-c
typedef enum : NSInteger
{
    RCPopoverViewAnimationStyleExpandFade,
    RCPopoverViewAnimationtyleFromBottom
} RCPopoverViewAnimationStyle;
```

## Credits

RCPopoverView is created by Robin Chou. Much of the code is inspired by the awesome cocoa classes offered by Sam Vermette (SVProgressHUD).
