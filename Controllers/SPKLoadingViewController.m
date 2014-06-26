//
//  SPKLoadingViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKLoadingViewController.h"
#import "SPKSpark.h"

@interface SPKLoadingViewController ()

@end

@implementation SPKLoadingViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![[SPKSpark sharedInstance].user found]) {
        if ([[SPKSpark sharedInstance] attemptedLogin]) {
            [self performSegueWithIdentifier:@"login" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"register" sender:nil];
        }
    } else {
        [[SPKSpark sharedInstance].webClient cores:^(NSArray *cores) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (SPKCore *core in cores) {
                    [[SPKSpark sharedInstance] addCore:core];
                    [[SPKSpark sharedInstance] activateCore:core];
                    
                }

                if ([SPKSpark sharedInstance].cores.count) {
                    [self performSegueWithIdentifier:@"cores" sender:nil];
                } else {
                    [self performSegueWithIdentifier:@"settings" sender:nil];
                }
            });
        } failure:^{
            DDLogError(@"Problem getting list of cores");
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showLogin
{
    [self performSegueWithIdentifier:@"login" sender:nil];
}

@end
