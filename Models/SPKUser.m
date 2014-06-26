//
//  SPKUser.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKUser.h"
#import "KeychainItemWrapper.h"

#define KEYCHAIN_SERVICE            @"Spark API"
#define KEYCHAIN_IDENTIFIER         @"Account Information"

@interface SPKUser ()

@property (nonatomic, strong) KeychainItemWrapper *keychainWrapper;

@end

@implementation SPKUser

- (id)init
{
    if (self = [super init]) {
        _keychainWrapper = [[KeychainItemWrapper alloc] initWithAccount:KEYCHAIN_IDENTIFIER service:KEYCHAIN_SERVICE accessGroup:nil];
        _userId = [self.keychainWrapper objectForKey:(__bridge id)(kSecAttrGeneric)];
        _token = [self.keychainWrapper objectForKey:(__bridge id)(kSecValueData)];
    }
    
    return self;
}

- (BOOL)found
{
    return (self.userId != nil) && ([self.userId length]) && (self.token != nil) && ([self.token length]);
}

- (void)store
{
    [self.keychainWrapper setObject:self.userId forKey:(__bridge id)(kSecAttrGeneric)];
    [self.keychainWrapper setObject:self.token forKey:(__bridge id)(kSecValueData)];
}

// Reset the values in the keychain item, or create a new item if it doesn't already exist
- (void)clear
{
    [self.keychainWrapper resetKeychainItem];
    self.keychainWrapper = [[KeychainItemWrapper alloc] initWithAccount:KEYCHAIN_IDENTIFIER service:KEYCHAIN_SERVICE accessGroup:nil];
    self.userId = nil;
    self.password = nil;
    self.token = nil;
}

@end
