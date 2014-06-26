//
//  SPKCore.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, SPKCoreState) {
    SPKCoreStateUnknown,
    SPKCoreStateHello,
    SPKCoreStateAttached,
    SPKCoreStateReady,
    SPKCoreStateAlreadyClaimed,
    SPKCoreStateFailed
};

@interface SPKCore : NSObject

@property (nonatomic, copy) NSData *coreId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) SPKCoreState state;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, assign) BOOL connected;

@property (nonatomic, readonly) NSArray *pins;

- (void)reset;

@end
