//
//  SPKSpark.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKSpark.h"
#import "SPKWebClient.h"
#import "SPKCore.h"
#import "NSData+HexString.h"

@interface SPKSpark ()

@property (nonatomic, strong) dispatch_queue_t workQueue;
@property (nonatomic, strong) dispatch_queue_t coreQueue;
@property (nonatomic, strong) dispatch_queue_t retryQueue;
@property (nonatomic, strong) NSMutableDictionary *coresInternal;
@property (nonatomic, strong) SPKCore *activeCore;

@end

@implementation SPKSpark

+ (SPKSpark *)sharedInstance
{
    static SPKSpark *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SPKSpark alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _user = [[SPKUser alloc] init];
        _webClient = [[SPKWebClient alloc] initWithUser:_user];
        _smartConfig = [[SPKSmartConfig alloc] init];
        _coresInternal = [NSMutableDictionary dictionaryWithCapacity:10];
        _coreQueue = dispatch_queue_create("Spark Core", DISPATCH_QUEUE_SERIAL);
        _workQueue = dispatch_queue_create("Spark Work", DISPATCH_QUEUE_CONCURRENT);
        _retryQueue = dispatch_queue_create("Spark Retry", DISPATCH_QUEUE_CONCURRENT);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreConfig:) name:kSPKSmartConfigConfigCore object:self.smartConfig];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreHello:) name:kSPKSmartConfigHelloCore object:self.smartConfig];
    }
    
    return self;
}

- (void)clearCores
{
    dispatch_sync(self.coreQueue, ^{
        [self.coresInternal removeAllObjects];
    });
}

- (NSArray *)cores
{
    __block NSArray *filtedCores;

    dispatch_sync(self.coreQueue, ^{
        filtedCores = [[SPKSpark sharedInstance].coresInternal.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state != %d", SPKCoreStateAlreadyClaimed]];
    });

    return filtedCores;
}

- (void)addCore:(SPKCore *)core
{
    dispatch_sync(self.coreQueue, ^{
        if (![self.coresInternal.allKeys containsObject:core.coreId]) {
            self.coresInternal[core.coreId] = core;
        }
    });
}

- (NSArray *)coresInState:(SPKCoreState)state
{
    __block NSArray *filtedCores;

    dispatch_sync(self.coreQueue, ^{
        filtedCores = [[SPKSpark sharedInstance].coresInternal.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"state == %d", state]];
    });

    return filtedCores;
}

- (void)activateCore:(SPKCore *)core
{
    dispatch_sync(self.coreQueue, ^{
        self.activeCore = core;
    });
}

#pragma mark - Smart Config Delegate

- (void)coreConfig:(NSNotification *)notification
{
    // When the Smart Config mDNS signal is received, simply ignore it
    DDLogInfo(@"Core SmartConfig detected");
}

- (void)coreHello:(NSNotification *)notification
{
    
    NSData *coreId = notification.userInfo[@"coreId"];
    DDLogInfo(@"Core Hello'd with CoreId: %@", [coreId hexString]);
    
    SPKCore *core = self.coresInternal[coreId];
    
    if (!core) {
        core = [[SPKCore alloc] init];
        core.coreId = coreId;
        [self addCore:core];
    }
    
    if (core.state != SPKCoreStateHello) {
        core.state = SPKCoreStateHello;
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, self.workQueue, ^(void) {
            DDLogVerbose(@"Calling handleHello");
            [self handleHello:core retryCount:0];
        });
    }
}

- (void)handleHello:(SPKCore *)core retryCount:(NSUInteger)retryCount
{
        
#if TARGET_IPHONE_SIMULATOR
    core.state = SPKCoreStateAttached;
    core.connected = YES;
#else
    dispatch_sync(self.coreQueue, ^{
            
        DDLogVerbose(@"Handling Core");
    
        [[SPKSpark sharedInstance].webClient attach:core.coreId success:^(NSData *coreId) {
            core.connected = YES;
            core.state = SPKCoreStateAttached;
            
            self.activeCore = core;

            [[NSNotificationCenter defaultCenter] postNotificationName:kSPKSmartConfigHelloCore object:self userInfo:@{ @"coreId" : core.coreId }];
        } offline:^ {
            if (retryCount < 3) {
                DDLogVerbose(@"Retrying Core");
                double delayInSeconds = 5.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, self.retryQueue, ^(void) {
                    [self handleHello:core retryCount:retryCount+1];
                });
            } else {
                core.connected = NO;
                core.state = SPKCoreStateFailed;
                DDLogVerbose(@"Giving up trying to claim Core");
            }
        } alreadyClaimed:^ {
            core.state = SPKCoreStateAlreadyClaimed;
            DDLogVerbose(@"Core already claimed, skipping");
        } failure:^(NSString *message) {
            core.connected = NO;
            core.state = SPKCoreStateFailed;
            DDLogWarn(@"Problem attaching core: %@", message);
        }];
    });
#endif
}

@end
