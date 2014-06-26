//
//  SPKCorePin.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKCorePin.h"

@interface SPKCorePin ()

@property (nonatomic, assign) BOOL valueSet;
@property (nonatomic, assign) NSUInteger value;

@end

@implementation SPKCorePin

- (id)initWithLabel:(NSString *)label side:(SPKCorePinSide)side row:(NSUInteger)row availableFunctions:(SPKCorePinFunction)availableFunctions
{
    if (self = [super init]) {
        _label = label;
        _side = side;
        _row = row;
        _availableFunctions = availableFunctions;
        _selectedFunction = SPKCorePinFunctionNone;


//        SPKCorePinFunction functions[] = { SPKCorePinFunctionNone, SPKCorePinFunctionAnalogRead, SPKCorePinFunctionAnalogWrite, SPKCorePinFunctionDigitalRead, SPKCorePinFunctionDigitalWrite };
//        BOOL stop;
//        do {
//            SPKCorePinFunction randomFunction = functions[rand() % 5];
//            if ((randomFunction & availableFunctions) == randomFunction) {
//                _selectedFunction = randomFunction;
//                stop = YES;
//            }
//        } while (!stop);
//
//        if (SPKCorePinFunctionAnalog(self)) {
//            _value = rand() % 1000;
//        } else {
//            _value = rand() % 2 == 0;
//        }
    }

    return self;
}

- (void)resetValue
{
    self.valueSet = NO;
    self.value = 0;
}

- (void)adjustValue:(NSUInteger)newValue
{
    self.value = newValue;
    self.valueSet = YES;
}

- (UIColor *)selectedFunctionColor
{
    switch (self.selectedFunction) {
        case SPKCorePinFunctionDigitalRead:
            return SPKCorePinFunctionDigitalReadColor;
        case SPKCorePinFunctionDigitalWrite:
            return SPKCorePinFunctionDigitalWriteColor;
        case SPKCorePinFunctionAnalogRead:
            return SPKCorePinFunctionAnalogReadColor;
        case SPKCorePinFunctionAnalogWrite:
            return SPKCorePinFunctionAnalogWriteColor;
        default:
            return SPKCorePinFunctionNoneColor;
    }
}

@end
