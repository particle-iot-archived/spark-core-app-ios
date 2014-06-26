//
//  SPKSmartConfig.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSPKSmartConfigConfigCore       @"kSPKSmartConfigConfigCore"
#define kSPKSmartConfigHelloCore        @"kSPKSmartConfigHelloCore"

/*
    This is a custom implementation of TI's SmartConfig protocol. This implementation uses GCD and
    GCDAsyncSocket for better responsiveness and mananagement.
 
 */
@interface SPKSmartConfig : NSObject

@property (nonatomic, copy) NSString *wifiPassword;
@property (nonatomic, copy) NSString *aesKey;
@property (nonatomic, readonly) BOOL isBroadcasting;

- (void)configureWithPassword:(NSString *)wifiPassword aesKey:(NSString *)aesKey;
- (void)startTransmittingSettings;
- (void)stopTransmittingSettings;
- (void)stopCoAPListening;

@end
