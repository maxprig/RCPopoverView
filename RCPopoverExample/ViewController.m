//
//  ViewController.m
//  RCPopoverExample
//
//  Created by Robin Chou on 4/9/13.
//  Copyright (c) 2013 Robin Chou. All rights reserved.
//

#import "ViewController.h"
#import "RCPopoverView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPopover:(id)sender {
    [RCPopoverView show];
}
@end
