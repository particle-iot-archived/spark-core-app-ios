//
//  SPKSettingsViewController.h
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPKSettingsViewController : UIViewController

@property (weak) IBOutlet UILabel *userLabel;

- (IBAction)logout:(id)sender;
- (IBAction)supprt:(id)sender;
- (IBAction)homepage:(id)sender;
- (IBAction)buildAnApp:(id)sender;
- (IBAction)documentation:(id)sender;
- (IBAction)contribute:(id)sender;
- (IBAction)reportBug:(id)sender;

@end
