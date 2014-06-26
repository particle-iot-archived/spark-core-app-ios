//
//  SPKTinkerViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPKCorePinView.h"
#import "SPKPinFunctionView.h"

/*
    This controller manages all aspects of Tinker including sub views via delegates. Any Tinker
    functionallity should following the same delegate pattern.
 */
@interface SPKTinkerViewController : UIViewController <SPKCorePinViewDelegate, SPKPinFunctionDelegate>

@property (weak) IBOutlet SPKPinFunctionView *pinFunctionView;
@property (weak) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UIView *firstTimeView;
@property (weak) IBOutlet UIImageView *tinkerLogoImageView;
@property (weak) IBOutlet UIImageView *shadowImageView;

@end
