//
//  SPKTinkerViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKTinkerViewController.h"
#import "SPKCore.h"
#import "SPKCorePin.h"
#import "SPKSpark.h"

@interface SPKTinkerViewController ()

@property (nonatomic, strong) NSMutableDictionary *pinViews;

@end

@implementation SPKTinkerViewController

- (void)viewDidLoad
{
    self.pinViews = [NSMutableDictionary dictionaryWithCapacity:16];

    self.pinFunctionView.delegate = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFirstTime)];
    [self.firstTimeView addGestureRecognizer:tap];

    SPKCore *activeCore = [SPKSpark sharedInstance].activeCore;

    for (SPKCorePin *pin in activeCore.pins) {
        SPKCorePinView *v = [[SPKCorePinView alloc] init];
        v.pin = pin;
        v.delegate = self;
        self.pinViews[pin.label] = v;
        [self.view insertSubview:v belowSubview:self.nameLabel];
    }

    if (!isiPhone5) {
        self.shadowImageView.hidden = YES;
        self.nameLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    SPKCore *activeCore = [SPKSpark sharedInstance].activeCore;

    for (SPKCorePin *pin in activeCore.pins) {
        SPKCorePinView *v = self.pinViews[pin.label];
        v.pin = pin;
    }

    self.nameLabel.text = activeCore.name;

    self.firstTimeView.hidden = ![SPKSpark sharedInstance].user.firstTime;
    self.tinkerLogoImageView.hidden = NO;
    self.nameLabel.hidden = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (!isiPhone5) {
        CGRect f = self.nameLabel.frame;
        f.origin.y = 340.0;
        self.nameLabel.frame = f;

        f = self.firstTimeView.frame;
        f.origin.y += 1.0;
        self.firstTimeView.frame = f;

        f = self.tinkerLogoImageView.frame;
        f.origin.y -= 30.0;
        self.tinkerLogoImageView.frame = f;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Pin Function Delegate

- (void)pinFunctionSelected:(SPKCorePinFunction)function
{
    SPKCorePin *pin = self.pinFunctionView.pin;
    pin.selectedFunction = function;
    self.pinFunctionView.pin = pin;

    SPKCorePinView *pinView = self.pinViews[pin.label];
    [pinView.pin resetValue];
    [pinView refresh];
}

#pragma mark - Core Pin View Delegate

- (void)pinViewAdjusted:(SPKCorePinView *)pinView newValue:(NSUInteger)newValue
{
    [pinView.pin adjustValue:newValue];

    [pinView noslider];
    [pinView refresh];
    [pinView activate];
    [self pinCallHome:pinView];
    for (SPKCorePinView *pv in self.pinViews.allValues) {
        [pv showDetails];
    }
}

- (void)pinViewHeld:(SPKCorePinView *)pinView
{
    if (![self slidingAnalogWritePinView] && !pinView.active) {
        [self showFunctionView:pinView];
    }
}

- (void)pinViewTapped:(SPKCorePinView *)pinView inPin:(BOOL)inPin
{
    if (!self.pinFunctionView.hidden) {
        self.pinFunctionView.hidden = YES;
        for (SPKCorePinView *pv in self.pinViews.allValues) {
            pv.alpha = 1.0;
        }
        self.tinkerLogoImageView.hidden = NO;
        self.nameLabel.hidden = NO;
    } else if (!pinView.active) {
        SPKCorePinView *slidingAnalogWritePinView = [self slidingAnalogWritePinView];

        if (!slidingAnalogWritePinView && pinView.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
            for (SPKCorePinView *pinView in self.pinViews.allValues) {
                [pinView hideDetails];
            }

            self.tinkerLogoImageView.hidden = YES;
            if (!isiPhone5) {
                self.nameLabel.hidden = YES;
            }
            [self.view bringSubviewToFront:pinView];
            [pinView slider];
        } else if (!slidingAnalogWritePinView && inPin && pinView.pin.selectedFunction == SPKCorePinFunctionNone) {
            [self showFunctionView:pinView];
        } else if (!slidingAnalogWritePinView && pinView.pin.selectedFunction == SPKCorePinFunctionDigitalWrite) {
            if (!pinView.pin.valueSet) {
                [pinView.pin adjustValue:1];
            } else {
                [pinView.pin adjustValue:!pinView.pin.value];
            }

            [pinView refresh];
            [pinView activate];
            [self pinCallHome:pinView];
        } else if (!slidingAnalogWritePinView && inPin) {
            if (pinView.pin.selectedFunction == SPKCorePinFunctionAnalogRead || pinView.pin.selectedFunction == SPKCorePinFunctionDigitalRead) {
                [pinView showDetails];
                [self.view bringSubviewToFront:pinView];
                [pinView activate];
                [self pinCallHome:pinView];
            }
        } else if (slidingAnalogWritePinView && pinView != slidingAnalogWritePinView) {
            [slidingAnalogWritePinView noslider];
            [slidingAnalogWritePinView refresh];
            [slidingAnalogWritePinView activate];
            [self pinCallHome:slidingAnalogWritePinView];
            for (SPKCorePinView *pinView in self.pinViews.allValues) {
                [pinView showDetails];
            }
        }
    }
}

#pragma mark - Private Methods

- (void)dismissFirstTime
{
    self.firstTimeView.hidden = YES;
    [SPKSpark sharedInstance].user.firstTime = NO;
}

- (void)showFunctionView:(SPKCorePinView *)pinView
{
    if (self.pinFunctionView.hidden) {
        self.tinkerLogoImageView.hidden = YES;
        if (!isiPhone5) {
            self.nameLabel.hidden = YES;
        }
        self.pinFunctionView.pin = pinView.pin;
        self.pinFunctionView.hidden = NO;
        for (SPKCorePinView *pv in self.pinViews.allValues) {
            if (pv != pinView) {
                pv.alpha = 0.1;
            }
        }
        [self.view bringSubviewToFront:self.pinFunctionView];
    }
}

- (SPKCorePinView *)slidingAnalogWritePinView
{
    for (SPKCorePinView *pv in self.pinViews.allValues) {
        if (pv.pin.selectedFunction == SPKCorePinFunctionAnalogWrite && pv.sliding) {
            return pv;
        }
    }

    return nil;
}

- (void)pinCallHome:(SPKCorePinView *)pinView
{
    [[SPKSpark sharedInstance].webClient coreId:[SPKSpark sharedInstance].activeCore.coreId pin:pinView.pin.label function:pinView.pin.selectedFunction value:pinView.pin.value success:^(NSUInteger value) {
        [SPKSpark sharedInstance].activeCore.connected = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pinView.pin.selectedFunction == SPKCorePinFunctionDigitalWrite || pinView.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
                if (value == -1) {
                    [[[UIAlertView alloc] initWithTitle:@"Core Pin" message:@"There was a problem writing to this pin." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    [pinView.pin resetValue];
                }
            } else {
                [pinView.pin adjustValue:value];
            }

            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [pinView deactivate];
            self.tinkerLogoImageView.hidden = NO;
            self.nameLabel.hidden = NO;
            [pinView refresh];
            [CATransaction commit];
        });
    } failure:^(NSString *errorMessage) {
        [SPKSpark sharedInstance].activeCore.connected = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Core Pin" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [pinView.pin resetValue];
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [pinView deactivate];
            self.tinkerLogoImageView.hidden = NO;
            self.nameLabel.hidden = NO;
            [pinView refresh];
            [CATransaction commit];
        });
    }];
}

@end
