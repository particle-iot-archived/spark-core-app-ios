//
//  SPKTimer.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    A GCD based recurring timer
 */
@interface SPKTimer : NSObject

+ (SPKTimer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

- (void)invalidate;

@end
