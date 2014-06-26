    //
//  SPKCoreNamingViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKCoreNamingViewController.h"
#import "SPKCore.h"
#import "SPKSpark.h"

@interface SPKCoreNamingViewController ()

@property (nonatomic, strong) SPKCore *currentCore;

@end

@implementation SPKCoreNamingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSArray *cores = [[SPKSpark sharedInstance] coresInState:SPKCoreStateAttached];
    
    self.currentCore = [cores firstObject];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreHello:) name:kSPKSmartConfigHelloCore object:[SPKSpark sharedInstance]];

    [self updateTitle];
    self.nameTextField.text = self.currentCore.name;
    self.infoLabel.text = @"Name the Core that's shouting rainbows at you.";

    self.spinnerImageView.hidden = YES;
    
    [[SPKSpark sharedInstance].webClient signal:self.currentCore.coreId on:YES];

#if TARGET_IPHONE_SIMULATOR
    uint8_t coreId[] = { 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02 };
    NSNotification *notification = [[NSNotification alloc] initWithName:kSPKSmartConfigHelloCore object:[SPKSpark sharedInstance].smartConfig userInfo:@{ @"coreId": [NSData dataWithBytes:coreId length:12] }];
    [[NSNotificationCenter defaultCenter] performSelectorInBackground:@selector(postNotification:) withObject:notification];
#endif

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSPKSmartConfigHelloCore object:[SPKSpark sharedInstance]];
    if ([SPKSpark sharedInstance].smartConfig.isBroadcasting) {
        [[SPKSpark sharedInstance].smartConfig stopTransmittingSettings];
        [[SPKSpark sharedInstance].smartConfig stopCoAPListening];
    }
}

- (CGFloat)keyboardHeightAdjust
{
    return 145.0;
}

- (void)dismissKeyboard
{
    if (self.nameTextField.isFirstResponder) {
        [self.nameTextField resignFirstResponder];
    }
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger length = [textField.text length];
    self.nameButton.enabled = (length > 1 || ![string isEqualToString:@""]);

    return YES;
}

#pragma mark - Smart Config Delegate

- (void)coreHello:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTitle];
    });
}

#pragma mark - Actions

- (IBAction)configureName:(id)sender
{
    NSString *name = self.nameTextField.text;

    [self spinSpinner:YES];

#if !TARGET_IPHONE_SIMULATOR
    [[SPKSpark sharedInstance].webClient name:self.currentCore.coreId label:name success:^ {
#endif
        self.currentCore.name = name;
        self.currentCore.state = SPKCoreStateReady;
        self.currentCore.connected = YES;
        [[SPKSpark sharedInstance].webClient signal:self.currentCore.coreId on:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self spinSpinner:NO];
            NSArray *cores = [[SPKSpark sharedInstance] coresInState:SPKCoreStateAttached];
            if (cores.count) {
                self.currentCore = [cores firstObject];
                self.nameTextField.text = self.currentCore.name;
                self.infoLabel.text = @"Core was named. Name the next one that's shouting rainbows at you.";
                [[SPKSpark sharedInstance].webClient signal:self.currentCore.coreId on:YES];
            } else {
                [self performSegueWithIdentifier:@"tinker" sender:nil];
            }
        });
#if !TARGET_IPHONE_SIMULATOR
    } failure:^{
        self.currentCore.connected = NO;
        self.currentCore.name = @"no-name-core";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self spinSpinner:NO];
            self.infoLabel.text = @"Failed to name core.";
        });
        DDLogError(@"Failed to name core");
    }];
#endif
}

#pragma mark - Private Methods

- (void)updateTitle
{
    NSUInteger count = [[[SPKSpark sharedInstance] coresInState:SPKCoreStateAttached] count];
    if (count == 1) {
        self.coresPendingLabel.text = @"We found a Core! Let's name it.";
    } else if (count > 1) {
        self.coresPendingLabel.text = [NSString stringWithFormat:@"We found %u Cores! Let's name them.", count];
    } else {
        self.coresPendingLabel.text = @"No new Cores found.";
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
