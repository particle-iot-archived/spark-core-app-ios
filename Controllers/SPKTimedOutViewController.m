//
//  SPKTimedOutViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKTimedOutViewController.h"
#import "SPKSpark.h"

@interface SPKTimedOutViewController ()

@end

@implementation SPKTimedOutViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.tinkerButton.hidden = [SPKSpark sharedInstance].cores.count == 0;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
