//
//  SPKNetworkSettingsViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKUIViewController.h"
#import "SPKSmartConfig.h"

/*
   This class will initiate SmartConfig broadcasting and listening
 */
@interface SPKNetworkSettingsViewController : SPKUIViewController

@property (weak) IBOutlet UITextField *ssidTextField;
@property (weak) IBOutlet UITextField *passwordTextField;
@property (weak) IBOutlet UITextField *keyTextField;
@property (weak) IBOutlet UIButton *connectButton;
@property (weak) IBOutlet UIButton *aesKeyButton;
@property (weak) IBOutlet UILabel *messageLabel;
@property (weak) IBOutlet UIImageView *keyBackgroundImageView;
@property (weak) IBOutlet UIButton *logoutButton;
@property (weak) IBOutlet UIButton *tinkerButton;
@property (weak) IBOutlet UIImageView *spinnerImageView;

- (IBAction)aesKeyToggle:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)logout:(id)sender;

@end
