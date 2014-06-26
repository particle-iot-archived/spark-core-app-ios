//
//  SPKSmartConfig.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <SystemConfiguration/CaptiveNetwork.h>

#import "SPKSmartConfig.h"
#import "GCDAsyncUdpSocket.h"
#import "FirstTimeConfig.h"

#include <arpa/inet.h>
#include <netinet/in.h>

#define COAP_MULTICAST_HOST             @"224.0.1.187"
#define COAP_MULTICAST_PORT             5683
#define COAP_MULTICAST_TIMEOUT          (60*5)

@interface SPKSmartConfig ()

@property (nonatomic, strong) FirstTimeConfig *firstTimeConfig;
@property (nonatomic, strong) GCDAsyncUdpSocket *coapListenSocket;
@property (nonatomic, strong) dispatch_queue_t coapListenQueue;

@property (nonatomic, assign) BOOL isBroadcasting;
@property (nonatomic, assign) BOOL isListening;

@end

@implementation SPKSmartConfig

- (id)init
{
    if (self = [super init]) {
        NSString *queueName = [NSString stringWithFormat:@"SPKSmartConfig-CoAPListen-%p", self];
        _coapListenQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        _coapListenSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_coapListenQueue];
    }
    
    return self;
}

- (void)configureWithPassword:(NSString *)wifiPassword aesKey:(NSString *)aesKey
{
    self.firstTimeConfig = [[FirstTimeConfig alloc] initWithKey:wifiPassword withEncryptionKey:[aesKey dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)startTransmittingSettings
{
    NSError *error;

    [self.coapListenSocket bindToPort:COAP_MULTICAST_PORT error:&error];
    if (error) {
        DDLogError(@"Problem setting up multicast: %@", [error localizedDescription]);
        return;
    }

    [self.coapListenSocket joinMulticastGroup:COAP_MULTICAST_HOST error:&error];
    if (error) {
        DDLogError(@"Problem setting up multicast: %@", [error localizedDescription]);
        return;
    }

    [self.coapListenSocket enableBroadcast:YES error:&error];
    if (error) {
        DDLogError(@"Problem setting up multicast: %@", [error localizedDescription]);
        return;
    }

    [self.coapListenSocket beginReceiving:&error];
    if (error) {
        DDLogError(@"Problem setting up multicast: %@", [error localizedDescription]);
        return;
    }

    [self.firstTimeConfig transmitSettings];

    self.isBroadcasting = YES;
    self.isListening = YES;

    DDLogInfo(@"Starting SmartConfig...");
}

- (void)stopTransmittingSettings
{
    DDLogInfo(@"Stopping SmartConfig...");
    self.isBroadcasting = NO;
    [self.firstTimeConfig stopTransmitting];
}

- (void)stopCoAPListening
{
    self.isListening = NO;
    [self.coapListenSocket close];
}

#pragma mark - Async Socket Delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (sock == self.coapListenSocket && self.isListening) {
        if (data.length >= 19) {
            uint8_t *bytes = (uint8_t *)[data bytes];
            if ((bytes[0] == 0x50) && (bytes[1] == 0x02) && (bytes[4] == 0xB1) && (bytes[5] == 0x68) && (bytes[6] == 0xFF)) {
                NSData *coreId = [NSData dataWithBytes:bytes+7 length:12];
                [[NSNotificationCenter defaultCenter] postNotificationName:kSPKSmartConfigHelloCore object:self userInfo:@{ @"coreId": coreId }];
                return;
            }
        }

        DDLogVerbose(@"Got smartConfigHelloed but isn't valid - dropping: %@", data);
    }
}

@end
