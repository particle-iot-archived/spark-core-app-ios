//
//  SPKWebClient.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "AFHTTPClient.h"
#import "SPKUser.h"
#import "SPKCorePin.h"

#define kSPKWebClientAuthenticationError    @"SPKWebClientAuthenticationError"
#define kSPKWebClientConnectionError        @"SPKWebClientConnectionError"
#define kSPKWebClientReachabilityChange     @"kSPKWebClientReachabilityChange"

@interface SPKWebClient : AFHTTPClient

- (id)initWithUser:(SPKUser *)user;

- (void)login:(void (^)(NSString *))authToken failure:(void (^)(NSString *))message;
- (void)register:(void (^)(NSString *))success failure:(void (^)(NSString *))failure;
- (void)attach:(NSData *)coreId success:(void (^)(NSData *))success offline:(void (^)(void))offline alreadyClaimed:(void (^)(void))alreadyClaimed failure:(void (^)(NSString *message))failure;
- (void)cores:(void (^)(NSArray *))cores failure:(void (^)(void))failure;
- (void)signal:(NSData *)coreId on:(BOOL)on;
- (void)name:(NSData *)coreId label:(NSString *)label success:(void (^)(void))success failure:(void (^)(void))failure;
- (void)flashTinker:(NSData *)coreId success:(void (^)(void))success failure:(void (^)(void))failure;
- (void)coreId:(NSData *)coreId pin:(NSString *)pin function:(SPKCorePinFunction)function value:(NSUInteger)value success:(void (^)(NSUInteger value))success failure:(void (^)(NSString *error))failure;

@end
