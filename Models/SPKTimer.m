//
//  SPKTimer.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKTimer.h"

@interface SPKTimer ()

@property (nonatomic, copy) dispatch_block_t block;
@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation SPKTimer

+ (SPKTimer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds queue:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    NSParameterAssert(seconds);
    NSParameterAssert(block);

    SPKTimer *timer = [[SPKTimer alloc] init];
    timer.block = block;
    timer.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    uint64_t nsec = (uint64_t)(seconds * NSEC_PER_SEC);
    dispatch_source_set_timer(timer.source, dispatch_time(DISPATCH_TIME_NOW, nsec), nsec, 0);
    dispatch_source_set_event_handler(timer.source, block);
    dispatch_resume(timer.source);
    return timer;
}

- (void)invalidate
{
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
    self.block = nil;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)fire
{
    self.block();
}

@end
