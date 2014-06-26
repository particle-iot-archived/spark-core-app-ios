//
//  SPKRegisterViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKUIViewController.h"

@interface SPKRegisterViewController : SPKUIViewController <UITextFieldDelegate>

@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UITextField *userIdTextField;
@property (weak) IBOutlet UITextField *passwordTextField;
@property (weak) IBOutlet UIButton *registerButton;
@property (weak) IBOutlet UIImageView *spinnerImageView;

@property (weak) IBOutlet UIButton *termsButton;
@property (weak) IBOutlet UIButton *privacyButton;

@property (weak) IBOutlet UIView *formView;
@property (weak) IBOutlet UIView *legalView;
@property (weak) IBOutlet UIImageView *logoImageView;

- (IBAction)register:(id)sender;
- (IBAction)terms:(id)sender;
- (IBAction)privacy:(id)sender;

@end
