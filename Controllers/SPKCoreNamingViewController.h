//
//  SPKCoreNamingViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKUIViewController.h"

/*
   This class will name Core(s) as well as manage SmartConfig broadcasting
 */
@interface SPKCoreNamingViewController : SPKUIViewController

@property (weak) IBOutlet UITextField *nameTextField;
@property (weak) IBOutlet UILabel *coresPendingLabel;
@property (weak) IBOutlet UILabel *infoLabel;
@property (weak) IBOutlet UIButton *nameButton;
@property (weak) IBOutlet UIImageView *spinnerImageView;

- (IBAction)configureName:(id)sender;

@end
