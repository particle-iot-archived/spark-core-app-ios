//
//  SPKUser.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    This class manages the user and includes keychain wrapping.
 */
@interface SPKUser : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL firstTime;

- (BOOL)found;
- (void)store;
- (void)clear;

@end
