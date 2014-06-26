//
//  SPKCorePin.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, SPKCorePinSide)
{
    SPKCorePinSideLeft,
    SPKCorePinSideRight
};

typedef NS_OPTIONS(uint8_t, SPKCorePinFunction)
{
    SPKCorePinFunctionNone              = 0,
    SPKCorePinFunctionDigitalRead       = 1 << 0,
    SPKCorePinFunctionDigitalWrite      = 1 << 1,
    SPKCorePinFunctionAnalogRead        = 1 << 2,
    SPKCorePinFunctionAnalogWrite       = 1 << 3
};

#define SPKCorePinFunctionNoneColor             [UIColor clearColor]
#define SPKCorePinFunctionDigitalReadColor      [UIColor colorWithRed:0.0 green:0.67 blue:0.93 alpha:1.0]
#define SPKCorePinFunctionDigitalWriteColor     [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0]
#define SPKCorePinFunctionAnalogReadColor       [UIColor colorWithRed:0.18 green:0.8 blue:0.44 alpha:1.0]
#define SPKCorePinFunctionAnalogWriteColor      [UIColor colorWithRed:0.95 green:0.77 blue:0.06 alpha:1.0]

#define SPKCorePinFunctionAnalog(pin)       ((pin.selectedFunction == SPKCorePinFunctionAnalogRead) || (pin.selectedFunction == SPKCorePinFunctionAnalogWrite))
#define SPKCorePinFunctionDigital(pin)      ((pin.selectedFunction == SPKCorePinFunctionDigitalRead) || (pin.selectedFunction == SPKCorePinFunctionDigitalWrite))
#define SPKCorePinFunctionNothing(pin)      (pin.selectedFunction == SPKCorePinFunctionNone)

@interface SPKCorePin : NSObject

@property (nonatomic, readonly) NSString *label;
@property (nonatomic, readonly) SPKCorePinSide side;
@property (nonatomic, readonly) NSUInteger row;
@property (nonatomic, readonly) SPKCorePinFunction availableFunctions;
@property (nonatomic, assign) SPKCorePinFunction selectedFunction;
@property (nonatomic, readonly) BOOL valueSet;
@property (nonatomic, readonly) NSUInteger value;

- (id)initWithLabel:(NSString *)label side:(SPKCorePinSide)side row:(NSUInteger)row availableFunctions:(SPKCorePinFunction)availableFunctions;

- (void)resetValue;
- (void)adjustValue:(NSUInteger)newValue;
- (UIColor *)selectedFunctionColor;

@end
