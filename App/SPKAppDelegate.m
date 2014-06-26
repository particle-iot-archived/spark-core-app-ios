//
//  SPKAppDelegate.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKAppDelegate.h"
#import "SPKSpark.h"
#import "SPKLoadingViewController.h"

@implementation SPKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationError:) name:kSPKWebClientAuthenticationError object:nil];

    SPKUser *user = [SPKSpark sharedInstance].user;

    if ([user found]) {
        DDLogInfo(@"Found User: %@", user.userId);
    } else {
        DDLogInfo(@"No User Found");
    }

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSNotification *notification = [NSNotification notificationWithName:kSPKWebClientReachabilityChange object:nil userInfo:@{ }];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

// This is called when an authentication error occurs from the web client
- (void)authenticationError:(NSNotification *)notification
{
    [SPKSpark sharedInstance].user.token = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spark Web" message:@"Authentication Error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    });
}

// After acknowledging the authentication error, go to the login screen
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SPKLoadingViewController *vc = (SPKLoadingViewController *)self.window.rootViewController;
    if (vc.presentedViewController) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    } else {
        [vc showLogin];
    }
}

@end
