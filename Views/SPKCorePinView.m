//
//  SPKCorePinView.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKCorePinView.h"

@interface SPKCorePinView ()

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL sliding;

@property (nonatomic, strong) CATextLayer *pinLabelLayer;
@property (nonatomic, strong) CAShapeLayer *pinRingLayer;

@property (nonatomic, strong) CAShapeLayer *barLayer;
@property (nonatomic, strong) CATextLayer *barLabelLayer;
@property (nonatomic, strong) CATextLayer *stateLabelLayer;
@property (nonatomic, strong) CALayer *activeLayer;
@property (nonatomic, strong) CALayer *bigActiveLayer;
@property (nonatomic, strong) CAShapeLayer *bigBarLayer;
@property (nonatomic, strong) CATextLayer *bigBarLabelLayer;
@property (nonatomic, strong) CAShapeLayer *bigBarSliderLayer;
@property (nonatomic, strong) CAShapeLayer *bigBarTailLayer;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *sliderGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, assign) NSUInteger originalPinValue;

@end

#define Y_OFFSET            (isiPhone5?64.0:68.0)
#define X_OFFSET            7.0
#define WIDTH               250.0
#define SPACING             (isiPhone5?24.0:22.0)
#define PADDING             2.0
#define RADIUS              13.5
#define DIAMETER            (RADIUS*2.0)
#define HEIGHT              (SPACING+RADIUS*2.0)
#define CENTER              (HEIGHT/2.0+2.0)
#define SCREEN_WIDTH        320.0
#define PIN_X_OFFSET        22.0
#define RING_OUTER_DIAMETER 35.0
#define RING_WIDTH          8.0

#define BAR_WIDTH           53.0
#define BAR_HEIGHT          9.0
#define BAR_X_OFFSET        10.0
#define BAR_LABEL_WIDTH     40.0

#define BIG_BAR_WIDTH       152.0
#define BIG_BAR_HEIGHT      9.0
#define BIG_BAR_LABEL_WIDTH 50.0
#define SLIDER_DIAMETER     16.0

#define STATE_WIDTH         BAR_WIDTH
#define STATE_HEIGHT        21.0

#define PIN_MAX_WRITE_VALUE 255.0
#define PIN_MAX_READ_VALUE  4096.0

@implementation SPKCorePinView

- (id)init
{
    if (self = [super init]) {
        _activeLayer = [CALayer layer];
        _activeLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30] CGColor];
        _activeLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_activeLayer];

        _bigActiveLayer = [CALayer layer];
        _bigActiveLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30] CGColor];
        _bigActiveLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_bigActiveLayer];

        _bigBarLayer = [CAShapeLayer layer];
        _bigBarLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.50] CGColor];
        _bigBarLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_bigBarLayer];

        _bigBarTailLayer = [CAShapeLayer layer];
        _bigBarTailLayer.backgroundColor = [[UIColor clearColor] CGColor];
        _bigBarTailLayer.fillColor = [[UIColor colorWithRed:0.945 green:0.769 blue:0.20 alpha:0.30] CGColor];
        _bigBarTailLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_bigBarTailLayer];

        _bigBarLabelLayer = [[CATextLayer alloc] init];
        [_bigBarLabelLayer setFont:@"HelveticaNeue-Medium"];
        [_bigBarLabelLayer setFontSize:14];
        _bigBarLabelLayer.foregroundColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.70] CGColor];
        _bigBarLabelLayer.bounds = CGRectMake(0.0, 0.0, BIG_BAR_LABEL_WIDTH, RADIUS+2.0);
        _bigBarLabelLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_bigBarLabelLayer];

        _bigBarSliderLayer = [CAShapeLayer layer];
        _bigBarSliderLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        _bigBarSliderLayer.fillColor = [[UIColor whiteColor] CGColor];
        _bigBarSliderLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_bigBarSliderLayer];

        _pinRingLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_pinRingLayer];

        _pinLabelLayer = [[CATextLayer alloc] init];
        [_pinLabelLayer setFont:@"HelveticaNeue-Medium"];
        [_pinLabelLayer setFontSize:13];
        _pinLabelLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_pinLabelLayer];

        _barLayer = [CAShapeLayer layer];
        _barLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.50] CGColor];
        _barLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_barLayer];

        _barLabelLayer = [[CATextLayer alloc] init];
        [_barLabelLayer setFont:@"HelveticaNeue-Medium"];
        [_barLabelLayer setFontSize:13];
        _barLabelLayer.foregroundColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.70] CGColor];
        _barLabelLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_barLabelLayer];

        _stateLabelLayer = [[CATextLayer alloc] init];
        [_stateLabelLayer setFont:@"HelveticaNeue-Book"];
        [_stateLabelLayer setFontSize:21];
        _stateLabelLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        _stateLabelLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:_stateLabelLayer];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinTapped:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        _tapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_tapGestureRecognizer];

        _sliderGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderPanned:)];
        _sliderGestureRecognizer.maximumNumberOfTouches = 1;
        _sliderGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_sliderGestureRecognizer];

        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPressGestureRecognizer.minimumPressDuration = 1.0;
        _longPressGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }

    return self;
}

- (void)setPin:(SPKCorePin *)pin
{
    _pin = pin;

    CGFloat x = pin.side == SPKCorePinSideLeft ? X_OFFSET : (SCREEN_WIDTH - X_OFFSET - WIDTH);
    CGRect f = CGRectMake(x, Y_OFFSET+pin.row*(HEIGHT+PADDING), WIDTH, HEIGHT);

    if (!isiPhone5) {
        f.origin.y -= 3.0;
    }

    self.frame = f;

    [self refresh];
}

- (void)refresh
{
    CGFloat pinX = self.pin.side == SPKCorePinSideRight ? (WIDTH-PIN_X_OFFSET) : PIN_X_OFFSET;
    CGFloat barX = self.pin.side == SPKCorePinSideRight ? (WIDTH-(BAR_X_OFFSET+RING_OUTER_DIAMETER)-BAR_WIDTH/2.0) : BAR_X_OFFSET+RING_OUTER_DIAMETER + BAR_WIDTH/2.0;
    CGFloat bigBarX = self.pin.side == SPKCorePinSideRight ? (WIDTH-(BAR_X_OFFSET+RING_OUTER_DIAMETER)-BIG_BAR_WIDTH/2.0) : BAR_X_OFFSET+RING_OUTER_DIAMETER + BIG_BAR_WIDTH/2.0;
    CGColorRef color = self.pin.selectedFunctionColor.CGColor;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    self.barLayer.hidden = YES;
    self.barLabelLayer.hidden = YES;
    self.stateLabelLayer.hidden = YES;
    self.activeLayer.hidden = YES;
    self.bigBarLayer.hidden = YES;
    self.bigBarLabelLayer.hidden = YES;
    self.bigBarSliderLayer.hidden = YES;
    self.bigBarTailLayer.hidden = YES;
    self.bigActiveLayer.hidden = YES;

    _activeLayer.hidden = !self.active;

    _bigBarLayer.fillColor = color;
    _bigBarLayer.strokeColor = color;
    _barLayer.fillColor = color;
    _barLayer.strokeColor = color;

    if (self.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
        _activeLayer.bounds = CGRectMake(0.0, 0.0, PIN_X_OFFSET+BAR_WIDTH+RING_OUTER_DIAMETER+BAR_LABEL_WIDTH, self.frame.size.height);
        if (self.pin.side == SPKCorePinSideRight) {
            _activeLayer.position = CGPointMake(self.frame.size.width-(_activeLayer.bounds.size.width/2.0), CENTER);
        } else {
            _activeLayer.position = CGPointMake(_activeLayer.bounds.size.width/2.0, CENTER);
        }

        _bigActiveLayer.bounds = CGRectMake(0.0, 0.0, WIDTH, self.frame.size.height);
        if (self.pin.side == SPKCorePinSideRight) {
            _bigActiveLayer.position = CGPointMake(self.frame.size.width-(_bigActiveLayer.bounds.size.width/2.0), CENTER);
        } else {
            _bigActiveLayer.position = CGPointMake(_bigActiveLayer.bounds.size.width/2.0, CENTER);
        }

        // Big Bar
        CGFloat width = self.pin.value/PIN_MAX_WRITE_VALUE*BIG_BAR_WIDTH;
        if (self.pin.side == SPKCorePinSideLeft) {
            _bigBarLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, BIG_BAR_HEIGHT)].CGPath;
        } else {
            _bigBarLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(BIG_BAR_WIDTH-width, 0, width, BIG_BAR_HEIGHT)].CGPath;
        }
        _bigBarLayer.bounds = CGRectMake(0.0, 0.0, BIG_BAR_WIDTH, BIG_BAR_HEIGHT);
        _bigBarLayer.position = CGPointMake(bigBarX, CENTER);
        _bigBarLayer.masksToBounds = YES;
        _bigBarLayer.hidden = !self.active;

        if (self.pin.side == SPKCorePinSideLeft) {
            _bigBarTailLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(width, 0, 0, BIG_BAR_HEIGHT)].CGPath;
        } else {
            _bigBarTailLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(BIG_BAR_WIDTH-width, 0, 0, BIG_BAR_HEIGHT)].CGPath;
        }
        _bigBarTailLayer.bounds = CGRectMake(0.0, 0.0, BIG_BAR_WIDTH, BIG_BAR_HEIGHT);
        _bigBarTailLayer.position = CGPointMake(bigBarX, CENTER);
        _bigBarTailLayer.masksToBounds = YES;
        _bigBarTailLayer.hidden = !self.active;

        _bigBarLabelLayer.string = [NSString stringWithFormat:@"%u", self.pin.value];
        if (self.pin.side == SPKCorePinSideLeft) {
            _bigBarLabelLayer.alignmentMode = kCAAlignmentLeft;
            _bigBarLabelLayer.position = CGPointMake(bigBarX+BIG_BAR_WIDTH/2.0+BIG_BAR_LABEL_WIDTH/2.0+10.0, CENTER);
        } else {
            _bigBarLabelLayer.alignmentMode = kCAAlignmentRight;
            _bigBarLabelLayer.position = CGPointMake(bigBarX-BIG_BAR_WIDTH/2.0-BIG_BAR_LABEL_WIDTH/2.0-10.0, CENTER);
        }
        _bigBarLabelLayer.hidden = !self.active;

        _bigBarSliderLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SLIDER_DIAMETER, SLIDER_DIAMETER) cornerRadius:SLIDER_DIAMETER/2.0].CGPath;
        _bigBarSliderLayer.bounds = CGRectMake(0.0, 0.0, SLIDER_DIAMETER, SLIDER_DIAMETER);
        _bigBarSliderLayer.cornerRadius = SLIDER_DIAMETER/2.0;
        if (self.pin.side == SPKCorePinSideLeft) {
            _bigBarSliderLayer.position = CGPointMake(bigBarX-BIG_BAR_WIDTH/2.0+width, CENTER);
        } else {
            _bigBarSliderLayer.position = CGPointMake(bigBarX+BIG_BAR_WIDTH/2.0-width, CENTER);
        }
        _bigBarSliderLayer.hidden = !self.active;

    } else if (self.pin.selectedFunction == SPKCorePinFunctionAnalogRead) {
        _activeLayer.bounds = CGRectMake(0.0, 0.0, PIN_X_OFFSET+BAR_WIDTH+RING_OUTER_DIAMETER+BAR_LABEL_WIDTH, self.frame.size.height);
        if (self.pin.side == SPKCorePinSideRight) {
            _activeLayer.position = CGPointMake(self.frame.size.width-(_activeLayer.bounds.size.width/2.0), CENTER);
        } else {
            _activeLayer.position = CGPointMake(_activeLayer.bounds.size.width/2.0, CENTER);
        }
    } else if (SPKCorePinFunctionDigital(self.pin)) {
        _activeLayer.bounds = CGRectMake(0.0, 0.0, PIN_X_OFFSET+RING_OUTER_DIAMETER+STATE_WIDTH, self.frame.size.height);
        if (self.pin.side == SPKCorePinSideRight) {
            _activeLayer.position = CGPointMake(self.frame.size.width-(_activeLayer.bounds.size.width/2.0), CENTER);
        } else {
            _activeLayer.position = CGPointMake(_activeLayer.bounds.size.width/2.0, CENTER);
        }
    }

    if (SPKCorePinFunctionDigital(self.pin) && self.pin.valueSet) {
        if (self.pin.value) {
            _pinRingLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        } else {
            _pinRingLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30] CGColor];
        }
    } else {
        _pinRingLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30] CGColor];
    }

    _pinRingLayer.fillColor = [[UIColor clearColor] CGColor];
    _pinRingLayer.strokeColor = color;
    _pinRingLayer.lineWidth = RING_WIDTH;
    _pinRingLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, RING_OUTER_DIAMETER, RING_OUTER_DIAMETER) cornerRadius:RING_OUTER_DIAMETER/2.0].CGPath;
    _pinRingLayer.bounds = CGRectMake(0.0, 0.0, DIAMETER+RING_WIDTH, DIAMETER+RING_WIDTH);
    _pinRingLayer.cornerRadius = RING_OUTER_DIAMETER/2.0;
    _pinRingLayer.position = CGPointMake(pinX, CENTER);
    _pinRingLayer.masksToBounds = YES;

    if (SPKCorePinFunctionAnalog(self.pin) || SPKCorePinFunctionNothing(self.pin) || !self.pin.valueSet) {
        _pinLabelLayer.foregroundColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.70] CGColor];
    } else {
        if (self.pin.value) {
            _pinLabelLayer.foregroundColor = [[UIColor blackColor] CGColor];
        } else {
            _pinLabelLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        }
    }
    _pinLabelLayer.bounds = CGRectMake(0.0, 0.0, 2.0*RADIUS, RADIUS);
    _pinLabelLayer.position = CGPointMake(pinX, ((SPACING+DIAMETER+PADDING)/2.0));
    _pinLabelLayer.string = self.pin.label;
    _pinLabelLayer.alignmentMode = kCAAlignmentCenter;

    if (SPKCorePinFunctionAnalog(self.pin)) {
        if (self.pin.valueSet) {
            CGFloat width;
            if (self.pin.selectedFunction == SPKCorePinFunctionAnalogRead) {
                width = self.pin.value/PIN_MAX_READ_VALUE*BAR_WIDTH;
            } else {
                width = self.pin.value/PIN_MAX_WRITE_VALUE*BAR_WIDTH;
            }
            if (self.pin.side == SPKCorePinSideLeft) {
                _barLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, BAR_HEIGHT)].CGPath;
            } else {
                _barLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(BAR_WIDTH-width, 0, width, BAR_HEIGHT)].CGPath;
            }
            _barLayer.bounds = CGRectMake(0.0, 0.0, BAR_WIDTH, BAR_HEIGHT);
            _barLayer.position = CGPointMake(barX, CENTER);
            _barLayer.masksToBounds = YES;
            _barLayer.hidden = self.active;

            _barLabelLayer.bounds = CGRectMake(0.0, 0.0, BAR_LABEL_WIDTH, RADIUS);
            _barLabelLayer.string = [NSString stringWithFormat:@"%u", self.pin.value];
            if (self.pin.side == SPKCorePinSideLeft) {
                _barLabelLayer.alignmentMode = kCAAlignmentRight;
                _barLabelLayer.position = CGPointMake(barX+BAR_WIDTH/2.0+BAR_LABEL_WIDTH/2.0, CENTER);
            } else {
                _barLabelLayer.alignmentMode = kCAAlignmentLeft;
                _barLabelLayer.position = CGPointMake(self.frame.size.width-(BAR_WIDTH+DIAMETER+RING_OUTER_DIAMETER), CENTER);
            }
            _barLabelLayer.hidden = self.active;
        }
    } else if (SPKCorePinFunctionDigital(self.pin)) {
        if (self.pin.valueSet) {
            _stateLabelLayer.bounds = CGRectMake(0.0, 0.0, STATE_WIDTH, STATE_HEIGHT);
            _stateLabelLayer.position = CGPointMake(barX, CENTER-2.0);
            _stateLabelLayer.string = self.pin.value ? @"HIGH" : @"LOW";
            if (self.pin.side == SPKCorePinSideLeft) {
                _stateLabelLayer.alignmentMode = kCAAlignmentLeft;
            } else {
                _stateLabelLayer.alignmentMode = kCAAlignmentRight;
            }
            _stateLabelLayer.hidden = NO;
        }
    } else if (SPKCorePinFunctionNothing(self.pin)) {
        // nothing
    }

    [CATransaction commit];
}

- (void)hideDetails
{
    self.activeLayer.hidden = YES;
    if (SPKCorePinFunctionDigital(self.pin)) {
        self.stateLabelLayer.hidden = YES;
    } else if (SPKCorePinFunctionAnalog(self.pin)) {
        self.barLabelLayer.hidden = YES;
        self.barLayer.hidden = YES;
    }
}

- (void)showDetails
{
    if (self.active) {
        self.activeLayer.hidden = NO;
    }
    if (SPKCorePinFunctionDigital(self.pin)) {
        self.stateLabelLayer.hidden = NO;
    } else if (SPKCorePinFunctionAnalog(self.pin)) {
        self.barLabelLayer.hidden = NO;
        self.barLayer.hidden = NO;
    }
}

- (void)noslider
{
    self.sliding = NO;
    if (self.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
        self.bigActiveLayer.hidden = YES;
        self.barLabelLayer.hidden = NO;
        self.barLayer.hidden = NO;
        self.bigBarLabelLayer.hidden = YES;
        self.bigBarLayer.hidden = YES;
        self.bigBarSliderLayer.hidden = YES;
        self.bigBarTailLayer.hidden = YES;
    }
}

- (void)slider
{
    self.originalPinValue = self.pin.value;
    self.sliding = YES;
    if (self.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
        self.bigActiveLayer.hidden = NO;
        self.barLabelLayer.hidden = YES;
        self.barLayer.hidden = YES;
        self.bigBarLabelLayer.hidden = NO;
        self.bigBarLayer.hidden = NO;
        self.bigBarSliderLayer.hidden = NO;
        self.bigBarTailLayer.hidden = NO;
    }
}

- (void)deactivate
{
    self.active = NO;
    self.activeLayer.hidden = YES;

    [self.activeLayer removeAnimationForKey:@"pulseAnimation"];
}

- (void)activate
{
    if (SPKCorePinFunctionNothing(self.pin)) {
        return;
    }

    self.active = YES;
    self.activeLayer.hidden = NO;

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    pulseAnimation.duration = 2.5;
    pulseAnimation.repeatCount = 1.0e100;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.toValue = (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.08] CGColor];
    [self.activeLayer addAnimation:pulseAnimation forKey:@"pulseAnimation"];
}

- (void)pinTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        if (((point.x <= 62) && (self.pin.side == SPKCorePinSideLeft)) ||
            ((point.x >= (self.frame.size.width - 62)) && (self.pin.side == SPKCorePinSideRight))) {
//        if ([self.pinRingLayer hitTest:point]) {
            [self.delegate pinViewTapped:self inPin:YES];
        } else {
            [self.delegate pinViewTapped:self inPin:NO];
        }
    }
}

- (void)sliderPanned:(UIPanGestureRecognizer *)sender
{
    if (!self.sliding) {
        return;
    }

    CGPoint point = [sender locationInView:self];
    CGFloat sliderXMin = self.bigBarSliderLayer.frame.origin.x - 35.0;
    CGFloat sliderXMax = self.bigBarSliderLayer.frame.origin.x + self.bigBarSliderLayer.bounds.size.width + 35.0;
    if (sliderXMin <= point.x && point.x <= sliderXMax) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];

        CGFloat xOffset = self.bigBarLayer.position.x - BIG_BAR_WIDTH/2.0;
        CGFloat origX;
        if (self.pin.selectedFunction == SPKCorePinFunctionAnalogRead) {
            origX = self.originalPinValue/PIN_MAX_READ_VALUE*BIG_BAR_WIDTH + xOffset;
        } else {
            origX = self.originalPinValue/PIN_MAX_WRITE_VALUE*BIG_BAR_WIDTH + xOffset;
        }

        CGFloat sliderX = point.x;

        if (sliderX > (xOffset + BIG_BAR_WIDTH)) {
            sliderX = xOffset + BIG_BAR_WIDTH;
        } else if (sliderX < xOffset) {
            sliderX = xOffset;
        }

        if (self.pin.side == SPKCorePinSideLeft) {
            if (sliderX < origX) {
                self.bigBarTailLayer.fillColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.30] CGColor];
                self.bigBarTailLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(sliderX-xOffset, 0, origX-sliderX, BIG_BAR_HEIGHT)].CGPath;
            } else if (sliderX > origX) {
                self.bigBarTailLayer.fillColor = [[UIColor colorWithRed:0.945 green:0.769 blue:0.20 alpha:0.30] CGColor];
                self.bigBarTailLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(origX-xOffset, 0, sliderX-origX, BIG_BAR_HEIGHT)].CGPath;
            } else {

            }
        } else {
            if (self.pin.selectedFunction == SPKCorePinFunctionAnalogRead) {
                origX = (BIG_BAR_WIDTH - self.originalPinValue/PIN_MAX_READ_VALUE*BIG_BAR_WIDTH) + xOffset;
            } else {
                origX = (BIG_BAR_WIDTH - self.originalPinValue/PIN_MAX_WRITE_VALUE*BIG_BAR_WIDTH) + xOffset;
            }
            if (sliderX < origX) {
                self.bigBarTailLayer.fillColor = [[UIColor colorWithRed:0.945 green:0.769 blue:0.20 alpha:0.30] CGColor];
                self.bigBarTailLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(sliderX-xOffset, 0, origX-sliderX, BIG_BAR_HEIGHT)].CGPath;
            } else {
                self.bigBarTailLayer.fillColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.30] CGColor];
                self.bigBarTailLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(origX-xOffset, 0, sliderX-origX, BIG_BAR_HEIGHT)].CGPath;
            }
        }

        NSUInteger newValue = 0;
        if (self.pin.side == SPKCorePinSideLeft) {
            newValue = sliderX-xOffset;
        } else {
            newValue = BIG_BAR_WIDTH-(sliderX-xOffset);
        }
        if (self.pin.selectedFunction == SPKCorePinFunctionAnalogRead) {
            self.bigBarLabelLayer.string = [NSString stringWithFormat:@"%lu", (unsigned long)(newValue/BIG_BAR_WIDTH*PIN_MAX_READ_VALUE)];
        } else {
            self.bigBarLabelLayer.string = [NSString stringWithFormat:@"%lu", (unsigned long)(newValue/BIG_BAR_WIDTH*PIN_MAX_WRITE_VALUE)];
        }

        self.bigBarSliderLayer.position = CGPointMake(sliderX, CENTER);

        [CATransaction commit];

        if (sender.state == UIGestureRecognizerStateEnded) {

        }

        if (sender.state == UIGestureRecognizerStateEnded) {
            if (self.pin.selectedFunction == SPKCorePinFunctionAnalogRead) {
                [self.delegate pinViewAdjusted:self newValue:(newValue/BIG_BAR_WIDTH*PIN_MAX_READ_VALUE)];
            } else {
                [self.delegate pinViewAdjusted:self newValue:(newValue/BIG_BAR_WIDTH*PIN_MAX_WRITE_VALUE)];
            }
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    [self.delegate pinViewHeld:self];
}

@end
