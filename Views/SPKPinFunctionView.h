//
//  SPKPinFunctionView.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPKCorePin.h"

@protocol SPKPinFunctionDelegate <NSObject>

- (void)pinFunctionSelected:(SPKCorePinFunction)function;

@end

/*
    A view to select a pins function.
 */
@interface SPKPinFunctionView : UIView

@property (weak) IBOutlet UILabel *pinLabel;
@property (weak) IBOutlet UIImageView *analogReadImageView;
@property (weak) IBOutlet UIButton *analogReadHighButton;
@property (weak) IBOutlet UIButton *analogReadButton;
@property (weak) IBOutlet UIImageView *analogWriteImageView;
@property (weak) IBOutlet UIButton *analogWriteButton;
@property (weak) IBOutlet UIImageView *digitalReadImageView;
@property (weak) IBOutlet UIButton *digitalReadHighButton;
@property (weak) IBOutlet UIButton *digitalReadButton;
@property (weak) IBOutlet UIImageView *digitalWriteImageView;
@property (weak) IBOutlet UIButton *digitalWriteButton;

@property (nonatomic, strong) SPKCorePin *pin;
@property (nonatomic, weak) NSObject<SPKPinFunctionDelegate> *delegate;

- (IBAction)functionSelected:(id)sender;

@end
