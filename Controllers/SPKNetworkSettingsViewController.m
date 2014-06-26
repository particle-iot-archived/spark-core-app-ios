//
//  SPKNetworkSettingsViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKNetworkSettingsViewController.h"
#import "SPKSpark.h"
#import "NSData+HexString.h"
#import "SPKCore.h"
#import "SPKTimer.h"
#import "FirstTimeConfig.h"

@interface SPKNetworkSettingsViewController ()

@property (nonatomic, strong) SPKSmartConfig *smartConfig;
@property (nonatomic, strong) dispatch_queue_t timerQueue;
@property (nonatomic, strong) SPKTimer *timer;

@end

@implementation SPKNetworkSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.smartConfig = [SPKSpark sharedInstance].smartConfig;
    self.timerQueue = dispatch_queue_create("networkSettingsTimer", DISPATCH_QUEUE_SERIAL);

    self.ssidTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.ssidTextField.leftViewMode = UITextFieldViewModeAlways;

    self.passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;

    self.keyTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.keyTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreHello:) name:kSPKSmartConfigHelloCore object:[SPKSpark sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiChanged:) name:kSPKWebClientReachabilityChange object:nil];

    self.messageLabel.text = @"";
    self.passwordTextField.text = @"";
    self.keyTextField.text = @"";
    self.ssidTextField.text = @"";

    if ([[[SPKSpark sharedInstance] coresInState:SPKCoreStateReady] count]) {
        self.logoutButton.hidden = YES;
        self.tinkerButton.hidden = NO;
    } else {
        self.logoutButton.hidden = NO;
        self.tinkerButton.hidden = YES;
    }

    self.spinnerImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self handleWifi];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSPKSmartConfigHelloCore object:[SPKSpark sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSPKWebClientReachabilityChange object:nil];
}

- (CGFloat)keyboardHeightAdjust
{
    if (isiPhone5) {
        return 145.0;
    } else {
        return 85.0;
    }
}

- (void)dismissKeyboard
{
    if (self.ssidTextField.isFirstResponder) {
        [self.ssidTextField resignFirstResponder];
    } else if (self.passwordTextField.isFirstResponder) {
        [self.passwordTextField resignFirstResponder];
    } else if (self.keyTextField.isFirstResponder) {
        [self.keyTextField resignFirstResponder];
    }
}

- (void)viewDidLayoutSubviews
{
    if (!isiPhone5) {
        CGRect f = self.logoutButton.frame;
        f.origin.y -= 76;
        self.logoutButton.frame = f;

        f = self.tinkerButton.frame;
        f.origin.y -= 76;
        self.tinkerButton.frame = f;
    }
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.keyTextField) {
        NSUInteger length = [textField.text length];
        self.connectButton.enabled = (length >= 15 && ![string isEqualToString:@""]);
        return [string isEqualToString:@""] || length <= 15;
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)connect:(id)sender
{
    if (self.smartConfig.isBroadcasting) {
        [self spinSpinner:NO];
        if ([[[SPKSpark sharedInstance] coresInState:SPKCoreStateReady] count]) {
            self.logoutButton.hidden = YES;
            self.tinkerButton.hidden = NO;
        } else {
            self.logoutButton.hidden = NO;
            self.tinkerButton.hidden = YES;
        }

        [self.timer invalidate];
        [self.smartConfig stopTransmittingSettings];
        [self.smartConfig stopCoAPListening];
        [self.connectButton setTitle:@"CONNECT" forState:UIControlStateNormal];
        [self.connectButton setBackgroundImage:[UIImage imageNamed:@"connect-btn"] forState:UIControlStateNormal];
        self.ssidTextField.enabled = YES;
        self.passwordTextField.enabled = YES;
        self.keyTextField.enabled = YES;
        self.messageLabel.text = @"";
    } else {
        self.logoutButton.hidden = YES;
        self.tinkerButton.hidden = YES;
        [self spinSpinner:YES];

        NSUInteger duration = 90.0;
#if TARGET_IPHONE_SIMULATOR
        duration = 20.0;
#endif
        self.timer = [SPKTimer repeatingTimerWithTimeInterval:duration queue:self.timerQueue block:^{
            [self timedOut];
        }];

        [self.connectButton setTitle:@"STOP" forState:UIControlStateNormal];
        [self.connectButton setBackgroundImage:[UIImage imageNamed:@"not-found-btn"] forState:UIControlStateNormal];
        self.ssidTextField.enabled = NO;
        self.passwordTextField.enabled = NO;
        self.keyTextField.enabled = NO;
        NSString *ipAddress = [FirstTimeConfig getGatewayAddress];
        DDLogInfo(@"Using router address: %@", ipAddress);
        NSString *aesKey = self.aesKeyButton.selected ? self.keyTextField.text : @"sparkdevices2013";
        [self.smartConfig configureWithPassword:self.passwordTextField.text aesKey:aesKey];
        [self.smartConfig startTransmittingSettings];

#if TARGET_IPHONE_SIMULATOR
        uint8_t coreId[] = { 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01 };
        NSNotification *notification = [[NSNotification alloc] initWithName:kSPKSmartConfigHelloCore object:[SPKSpark sharedInstance].smartConfig userInfo:@{ @"coreId": [NSData dataWithBytes:coreId length:12] }];
        [[NSNotificationCenter defaultCenter] performSelectorInBackground:@selector(postNotification:) withObject:notification];
#endif
    }
}

- (IBAction)aesKeyToggle:(id)sender
{
    UIButton *button = sender;
    button.selected = !button.selected;
    self.keyTextField.hidden = !button.selected;
    self.keyBackgroundImageView.hidden = !button.selected;
    if (button.selected) {
        self.connectButton.enabled = (self.keyTextField.text.length == 16);
    } else {
        self.connectButton.enabled = YES;
    }
}

- (IBAction)logout:(id)sender
{
    [[SPKSpark sharedInstance].user clear];
    [[SPKSpark sharedInstance] clearCores];
    [self spinSpinner:NO];
    [self performSegueWithIdentifier:@"login" sender:sender];
}

#pragma mark - Notifications

- (void)wifiChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleWifi];
    });
}

- (void)coreHello:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self spinSpinner:NO];
        [self performSegueWithIdentifier:@"connect" sender:nil];
    });
}

#pragma mark - Private Methods

- (void)timedOut
{
    [self.timer invalidate];
    if ([SPKSpark sharedInstance].smartConfig.isBroadcasting) {
        [[SPKSpark sharedInstance].smartConfig stopTransmittingSettings];
        [[SPKSpark sharedInstance].smartConfig stopCoAPListening];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self spinSpinner:NO];
        [self performSegueWithIdentifier:@"notfound" sender:nil];
    });
}

- (void)handleWifi
{
#if TARGET_IPHONE_SIMULATOR
    self.ssidTextField.text = @"Simulator";
#else
    if ([FirstTimeConfig getSSID]) {
        self.ssidTextField.text = [FirstTimeConfig getSSID];
        self.connectButton.enabled = YES;
    } else {
        [self spinSpinner:NO];
        self.ssidTextField.text = @"No Wifi";
        self.connectButton.enabled = NO;
        [[[UIAlertView alloc] initWithTitle:@"Smart Config Error" message:@"You must be connected to a Wi-Fi network to connect your Core." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
#endif
}

- (void)spinSpinner:(BOOL)go
{
    if (go) {
        self.spinnerImageView.hidden = NO;

        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        rotation.duration = 1.1; // Speed
        rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
        [self.spinnerImageView.layer addAnimation:rotation forKey:@"Spin"];
    } else {
        self.spinnerImageView.hidden = YES;
        [self.spinnerImageView.layer removeAllAnimations];
    }
}

@end
