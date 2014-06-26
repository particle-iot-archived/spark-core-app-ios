//
//  main.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPKAppDelegate.h"
#import "DDTTYLogger.h"
#import "SPKDevLogFormatter.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [[DDTTYLogger sharedInstance] setLogFormatter:[[SPKDevLogFormatter alloc] init]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SPKAppDelegate class]));
    }
}
