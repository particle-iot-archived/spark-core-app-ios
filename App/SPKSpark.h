//
//  SPKSpark.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SPKUser.h"
#import "SPKWebClient.h"
#import "SPKSmartConfig.h"
#import "SPKCore.h"

/*
    This is the main class for the application. It should only used as a singleton
    and any class should feel free to access it. There is no initialization needs
    to be done on it.
*/
@interface SPKSpark : NSObject

@property (nonatomic, readonly) SPKUser *user;
@property (nonatomic, assign) BOOL attemptedLogin;
@property (nonatomic, readonly) SPKWebClient *webClient;
@property (nonatomic, readonly) SPKSmartConfig *smartConfig;
@property (nonatomic, readonly) SPKCore *activeCore;

+ (SPKSpark *)sharedInstance;

- (void)clearCores;
- (NSArray *)cores;
- (void)addCore:(SPKCore *)core;
- (NSArray *)coresInState:(SPKCoreState)state;
- (void)activateCore:(SPKCore *)core;

@end
