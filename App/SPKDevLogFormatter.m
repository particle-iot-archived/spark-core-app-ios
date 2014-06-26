//
//  SPKDevLogFormatter.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKDevLogFormatter.h"

@interface SPKDevLogFormatter ()

@property (assign) uint8_t loggerCount;
@property (nonatomic, strong) NSDateFormatter *threadUnsafeDateFormatter;

@end

@implementation SPKDevLogFormatter

- (id)init
{
    if ((self = [super init])) {
        _threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [_threadUnsafeDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [_threadUnsafeDateFormatter setDateFormat:@"HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"E"; break;
        case LOG_FLAG_WARN  : logLevel = @"W"; break;
        case LOG_FLAG_INFO  : logLevel = @"I"; break;
        default             : logLevel = @"V"; break;
    }
    
    NSString *dateAndTime = [self.threadUnsafeDateFormatter stringFromDate:(logMessage->timestamp)];
    NSString *file = [[[NSString stringWithUTF8String:logMessage->file] componentsSeparatedByString:@"/"] lastObject];
    
    return [NSString stringWithFormat:@"%@|%@|%@:%d|%s|%@", logLevel, dateAndTime, file, logMessage->lineNumber, logMessage->function, logMessage->logMsg];
}

- (void)didAddToLogger:(id <DDLogger>)logger
{
    self.loggerCount++;
    NSAssert(self.loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger
{
    self.loggerCount--;
}

@end
