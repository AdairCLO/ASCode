//
//  ASCWXPickerCaptureButton.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerCaptureButton.h"

static const CGFloat KBigCircleSize_capture = 113;
static const CGFloat KSmallCircleSize_capture = 33;
static const CGFloat KBigCircleSize = 88;
static const CGFloat KSmallCircleSize = 64;
static const CGFloat KBigCircleRadius = KBigCircleSize / 2;
static const CGFloat kViewSize = KBigCircleSize_capture;
static const CGFloat kViewCenter = kViewSize / 2;
static const CGFloat kProgressCircleBorderWidth = 6;

static const NSUInteger kDefaultMaxVideoDurationSeconds = 15;

typedef NS_ENUM(NSInteger, ASCWXPickerCaptureButtonCaptureVideoState) {
    ASCWXPickerCaptureButtonCaptureVideoStateNone,
    ASCWXPickerCaptureButtonCaptureVideoStateStarting,
    ASCWXPickerCaptureButtonCaptureVideoStateCapturing,
};

@interface ASCWXPickerCaptureButton () <UIGestureRecognizerDelegate, CAAnimationDelegate>

@property (nonatomic, strong) CALayer *bigCircle;
@property (nonatomic, strong) CALayer *smallCircle;
@property (nonatomic, strong) CAShapeLayer *progressCircle;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *holdGestureRecognizer;
@property (nonatomic, assign) ASCWXPickerCaptureButtonCaptureVideoState captureVideoState;

@property (nonatomic, assign) NSUInteger maxVideoDurationSeconds;

@end

@implementation ASCWXPickerCaptureButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, kViewSize, kViewSize);
        
        _bigCircle = [CALayer layer];
        _bigCircle.backgroundColor = [UIColor colorWithRed:192/255.0 green:188/255.0 blue:184/255.0 alpha:1].CGColor;
        [self.layer addSublayer:_bigCircle];
        
        _smallCircle = [CALayer layer];
        _smallCircle.backgroundColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_smallCircle];
        
        _progressCircle = [CAShapeLayer layer];
        _progressCircle.lineWidth = kProgressCircleBorderWidth;
        _progressCircle.strokeColor = [UIColor colorWithRed:98/255.0 green:183/255.0 blue:93/255.0 alpha:1].CGColor;
        _progressCircle.fillColor = nil;
        _progressCircle.frame = CGRectMake(kProgressCircleBorderWidth / 2, kProgressCircleBorderWidth / 2, KBigCircleSize_capture - kProgressCircleBorderWidth, KBigCircleSize_capture - kProgressCircleBorderWidth);
        CGPathRef path = nil;
        UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.progressCircle.frame.size.width / 2, self.progressCircle.frame.size.width / 2)
                                                              radius:(self.progressCircle.frame.size.width / 2)
                                                          startAngle:-M_PI_2 endAngle:-M_PI_2 - 0.000001 clockwise:YES];
        path = bezier.CGPath;
        self.progressCircle.path = path;
        self.progressCircle.strokeEnd = 0;
        [self.layer addSublayer:_progressCircle];
        
        // the "tap gesture" should come first than the "hold gesture": because we need "capture image" than "stop capture video"
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        _holdGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onHold:)];
        _holdGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_holdGestureRecognizer];
        
        [self updateCircleFrame:NO];
        _captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateNone;
        _maxVideoDurationSeconds = kDefaultMaxVideoDurationSeconds;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (((point.x - kViewCenter) * (point.x - kViewCenter)
         + (point.y - kViewCenter) * (point.y - kViewCenter)
         - KBigCircleRadius * KBigCircleRadius) > 0)
    {
        // outside the circle
        return NO;
    }
    return YES;
}

#pragma mark - big/small circle frame size

- (void)updateCircleFrame:(BOOL)isCapture
{
    [self updateBigCircleFrame:isCapture];
    [self updateSmallCircleFrame:isCapture];
}

- (void)updateBigCircleFrame:(BOOL)isCapture
{
    self.bigCircle.frame = [self bigCircleFrame:isCapture];
    self.bigCircle.cornerRadius = self.bigCircle.frame.size.width / 2;
}

- (void)updateSmallCircleFrame:(BOOL)isCapture
{
    self.smallCircle.frame = [self smallCircleFrame:isCapture];
    self.smallCircle.cornerRadius = self.smallCircle.frame.size.width / 2;
}

- (CGRect)bigCircleFrame:(BOOL)isCapture
{
    CGFloat size = KBigCircleSize;
    if (isCapture)
    {
        size = KBigCircleSize_capture;
    }
    CGFloat margin = (kViewSize - size) / 2;
    return CGRectMake(margin, margin, size, size);
}

- (CGRect)smallCircleFrame:(BOOL)isCapture
{
    CGFloat size = KSmallCircleSize;
    if (isCapture)
    {
        size = KSmallCircleSize_capture;
    }
    CGFloat margin = (kViewSize - size) / 2;
    return CGRectMake(margin, margin, size, size);
}

#pragma mark - capture image/video

- (void)captureImage
{
    if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateStarting)
    {
        self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateNone;
    }
    else if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateCapturing)
    {
        [self cancelCaptureVideo];
    }
    else
    {
        // capture image animation
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self updateSmallCircleFrame:NO];
        }];
        [self updateSmallCircleFrame:YES];
        [CATransaction commit];
    }
    
    [self.delegate captureButtonDidCaptureImage:self];
}

- (void)startCaptureVideo
{
    if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateStarting
        || self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateCapturing)
    {
        return;
    }
    
    self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateStarting;
    
    // capture video animation
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateNone)
        {
            [self updateCircleFrame:NO];
        }
        else if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateStarting)
        {
            self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateCapturing;
            
            [self startCaptureProgressAnimation];
            [self.delegate captureButtonDidStartCaptureVideo:self];
        }
    }];
    [self updateCircleFrame:YES];
    [CATransaction commit];
}

- (void)stopCaptureVideo
{
    if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateStarting)
    {
        self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateNone;
    }
    else if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateCapturing)
    {
        self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateNone;
        
        [self updateCircleFrame:NO];
        [self stopCaptureProgressAnimation];
        [self.delegate captureButtonDidStopCaptureVideo:self];
    }
}

- (void)cancelCaptureVideo
{
    if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateStarting)
    {
        self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateNone;
    }
    else if (self.captureVideoState == ASCWXPickerCaptureButtonCaptureVideoStateCapturing)
    {
        self.captureVideoState = ASCWXPickerCaptureButtonCaptureVideoStateNone;
        
        [self updateCircleFrame:NO];
        [self stopCaptureProgressAnimation];
        [self.delegate captureButtonDidCancelCaptureVideo:self];
    }
}

- (void)startCaptureProgressAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = self.maxVideoDurationSeconds;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.progressCircle addAnimation:animation forKey:@"capture"];
}

- (void)stopCaptureProgressAnimation
{
    [self.progressCircle removeAllAnimations];
}

#pragma mark - gesture

- (void)onTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self captureImage];
}

- (void)onHold:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self startCaptureVideo];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self stopCaptureVideo];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self cancelCaptureVideo];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.holdGestureRecognizer)
    {
        return YES;
    }
    return NO;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        [self stopCaptureVideo];
    }
}

@end
