//
//  SPKCoreCell.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKCoreCell.h"
#import "SPKSpark.h"

@interface SPKCoreCell ()

@property (nonatomic, strong) CAShapeLayer *leftLayer;
@property (nonatomic, strong) CAShapeLayer *dotLayer;

@end

@implementation SPKCoreCell

- (void)awakeFromNib
{
    self.leftLayer = [CAShapeLayer layer];
    self.leftLayer.fillColor = [[UIColor redColor] CGColor];
    self.leftLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0.0, 5.0, 40.0)].CGPath;
    self.leftLayer.bounds = CGRectMake(0.0, 0.0, 5.0, 40.0);
    self.leftLayer.position = CGPointMake(2.5, 20.0);

    [self.layer addSublayer:self.leftLayer];

    self.dotLayer = [CAShapeLayer layer];
    self.dotLayer.fillColor = [[UIColor redColor] CGColor];
    self.dotLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 10.0, 10.0) cornerRadius:10.0/2.0].CGPath;
    self.dotLayer.bounds = CGRectMake(0.0, 0.0, 10.0, 10.0);
    self.dotLayer.cornerRadius = 10.0/2.0;
    self.dotLayer.position = CGPointMake(25.0, 21.0);

    [self.layer addSublayer:self.dotLayer];

    self.spinnerImageView.hidden = YES;
}

- (void)setCore:(SPKCore *)core
{
    _core = core;
    self.nameLabel.text = _core.name;
    self.leftLayer.fillColor = [_core.color CGColor];
    self.dotLayer.fillColor = [_core.color CGColor];
    self.connectLabel.text = [NSString stringWithFormat:@"Connected: %@", _core.connected ? @"Yes" : @"No"];
    if ([SPKSpark sharedInstance].activeCore == _core) {
        self.leftLayer.hidden = NO;
    } else {
        self.leftLayer.hidden = YES;
    }
}

- (void)expand
{
    [self.expandButton setImage:[UIImage imageNamed:@"20.03-down-arrow.png"] forState:UIControlStateNormal];
    self.editButton.hidden = NO;
    self.grayLineImageView.hidden = YES;
}

- (void)contract
{
    [self.expandButton setImage:[UIImage imageNamed:@"20.02-right-arrow.png"] forState:UIControlStateNormal];
    self.editButton.hidden = YES;
    self.grayLineImageView.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
