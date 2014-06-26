//
//  SPKLoginViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKUIViewController.h"

@interface SPKLoginViewController : SPKUIViewController

@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UITextField *userIdTextField;
@property (weak) IBOutlet UITextField *passwordTextField;
@property (weak) IBOutlet UIButton *loginButton;
@property (weak) IBOutlet UIImageView *spinnerImageView;

@property (weak) IBOutlet UIView *formView;
@property (weak) IBOutlet UIImageView *logoImageView;

- (IBAction)login:(id)sender;
- (IBAction)forgot:(id)sender;

@end
