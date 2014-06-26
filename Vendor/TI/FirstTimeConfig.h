/*
 * File: FirstTimeConfig.h
 * Copyright © 2013, Texas Instruments Incorporated - http://www.ti.com/
 * All rights reserved.
 */


#import <Foundation/Foundation.h>
//#import "FtcEncode.h"

@class FtcEncode;

@interface OSFailureException : NSException

@end

@interface FirstTimeConfig : NSObject {
    @private
    bool stopSending;
    NSCondition * stopSendingEvent;
    NSCondition * suspendSendingEvent;
    
    NSString * ip;
    NSString * ssid;
    NSString * key;
    int numberOfTries;

    int nSetup;
    int nSync;

    useconds_t delay;

    NSMutableData * sync1;
    NSMutableData * sync2;

    NSData * encryptionKey;
    FtcEncode * ftcData;
    NSData * sockAddr;
    
    int listenSocket;
    int abortWaitForAckEvent[2];
    short listenPort;
    
    NSThread * sendingThread;
    NSCondition * stoppedSending;
    NSCondition * watchdogFinished;
    NSCondition * ackThreadFinished;
    
    bool isWatchdogRunning;
    bool isSuspended;
    
    const NSString * remoteDeviceName;
}

/* The following procedure can throw an OSFailureException exception */
- (id)init;

/* The following procedure can throw an OSFailureException exception */
- (id)initWithKey:(NSString *)Key;

/* The following procedure can throw an OSFailureException exception */
- (id)initWithKey:(NSString *)Key withEncryptionKey:(NSData *)encryptionKey;

/* The following procedure can throw an OSFailureException exception */
- (id)initWithData:(NSString *)Ip withSSID:(NSString *)Ssid withKey:(NSString *)Key withEncryptionKey:(NSData *)EncryptionKey numberOfSetups:(int)numOfSetups numberOfSyncs:(int)numOfSyncs syncLength1:(int)lSync1 syncLength2:(int)lSync2 delayInMicroSeconds:(useconds_t)uDelay;

/* The following procedure can throw an OSFailureException exception */
- (void)stopTransmitting;

/* The following procedure can throw an OSFailureException exception */
- (void)transmitSettings;

/* The following procedure can throw an OSFailureException exception */
- (bool)waitForAck;

- (bool)isTransmitting;

- (void)setDeviceName:(const NSString *)deviceName;

+ (NSString *)getSSID;

+ (NSString *)getGatewayAddress;

@end
