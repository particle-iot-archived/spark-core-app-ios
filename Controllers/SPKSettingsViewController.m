//
//  SPKSettingsViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKSettingsViewController.h"
#import "SPKSpark.h"
#import "SPKLoadingViewController.h"

@interface SPKSettingsViewController ()

@end

@implementation SPKSettingsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.userLabel.text = [SPKSpark sharedInstance].user.userId;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)logout:(id)sender
{
    if ([SPKSpark sharedInstance].user) {
        [[SPKSpark sharedInstance].user clear];
        [[SPKSpark sharedInstance] clearCores];
        [self performSegueWithIdentifier:@"login" sender:sender];
    }
}

- (IBAction)supprt:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.spark.io/support"]];
}

- (IBAction)homepage:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.spark.io"]];
}

- (IBAction)buildAnApp:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.spark.io/build"]];
}

- (IBAction)documentation:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://docs.spark.io/"]];
}

- (IBAction)contribute:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://spark.github.io/"]];
}

- (IBAction)reportBug:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.github.com/particle-iot/ios-app/issues"]];
}

@end
