//
//  ASCWXPickerContentContainerView.m
//  ASCode
//
//  Created by Adair Wang on 2021/5/4.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerContentContainerView.h"

static const CGFloat kPadding = 10;
static const CGFloat kBorderWidth = 0.5;
static const NSTimeInterval kDelayDeactiveTime = 2;

static const CGFloat kScaleMin = 0.5;
static const CGFloat kScaleMax = 2.0;

@interface ASCWXPickerContentContainerView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotation;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;

@property (nonatomic, assign) CGFloat prevRotation;
@property (nonatomic, assign) CGFloat prevScale;
@property (nonatomic, assign) CGPoint prevTranslation;

@property (nonatomic, assign) CGFloat totalRotation;
@property (nonatomic, assign) CGFloat totalScale;
@property (nonatomic, assign) CGPoint totalTranslation;

@property (nonatomic, assign) NSUInteger transformCount;

@property (nonatomic, assign) CGPoint transformTouchPointInView;

@end

@implementation ASCWXPickerContentContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _totalRotation = 0;
        _totalScale = 1.0;
        _totalTranslation = CGPointZero;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tap];
        
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        _pan.delegate = self;
        [self addGestureRecognizer:_pan];
        
        _rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotation:)];
        _rotation.delegate = self;
        [self addGestureRecognizer:_rotation];

        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
        [self addGestureRecognizer:_pinch];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setContentView:(UIView *)contentView
{
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    [self addSubview:contentView];
    
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGPoint center = self.center;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentView.frame.size.width + kPadding + kPadding, contentView.frame.size.height + kPadding + kPadding);
    self.center = center;
    
    self.transform = currentTransform;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(kPadding, kPadding, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)active:(BOOL)autoDeactive
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self enableBorder:YES];
    if (autoDeactive)
    {
        [self performSelector:@selector(deactive) withObject:self afterDelay:kDelayDeactiveTime];
    }
}

- (void)deactive
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self enableBorder:NO];
}

- (BOOL)isActive
{
    return (self.layer.borderWidth > 0);
}

- (void)enableBorder:(BOOL)enable
{
    if (enable)
    {
        self.layer.borderWidth = kBorderWidth;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        self.layer.borderWidth = 0;
    }
}

- (void)resetTranslateTransform
{
    self.totalTranslation = CGPointZero;
    [self updateTransform];
}

- (void)updateTransform
{
    CGAffineTransform t = [self makeTransform];
    self.transform = t;
}

- (CGAffineTransform)makeTransform
{
    CGAffineTransform t_rotation = CGAffineTransformMakeRotation(self.totalRotation);
    CGAffineTransform t_scale = CGAffineTransformMakeScale(self.totalScale, self.totalScale);
    CGAffineTransform t_translation = CGAffineTransformMakeTranslation(self.totalTranslation.x, self.totalTranslation.y);
    
    CGAffineTransform t = CGAffineTransformConcat(t_rotation, t_scale);
    t = CGAffineTransformConcat(t, t_translation);
    return t;
}

- (void)tryNotifyTransform:(UIGestureRecognizerState)state
{
    if (state == UIGestureRecognizerStateBegan)
    {
        if (self.transformCount == 0 && self.transformBeganHandler != nil)
        {
            self.transformBeganHandler(self);
        }
        self.transformCount += 1;
    }
    else if (state == UIGestureRecognizerStateChanged)
    {
        if (self.transformMovedHandler != nil)
        {
            self.transformMovedHandler(self);
        }
    }
    else if (state == UIGestureRecognizerStateEnded
             || state == UIGestureRecognizerStateCancelled)
    {
        self.transformCount -= 1;
        if (self.transformCount == 0 && self.transformEndedHandler != nil)
        {
            self.transformEndedHandler(self);
        }
    }
}

#pragma mark - gesture

- (void)onTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.tapHandler != nil)
    {
        self.tapHandler(self);
    }
}

- (void)onPan:(UIPanGestureRecognizer *)gr
{
    UIGestureRecognizerState state = gr.state;
    if (state == UIGestureRecognizerStateBegan)
    {
        self.prevTranslation = CGPointZero;
    }
    
    if (state == UIGestureRecognizerStateBegan
        || state == UIGestureRecognizerStateChanged)
    {
        CGPoint p = [gr translationInView:gr.view.superview];
        
        self.totalTranslation = CGPointMake(self.totalTranslation.x + (p.x - self.prevTranslation.x), self.totalTranslation.y + (p.y - self.prevTranslation.y));
        self.prevTranslation = p;
        
        [self updateTransform];
        
        self.transformTouchPointInView = [gr locationOfTouch:0 inView:self];
    }
    
    [self tryNotifyTransform:state];
}

- (void)onRotation:(UIRotationGestureRecognizer *)gr
{
    UIGestureRecognizerState state = gr.state;
    if (state == UIGestureRecognizerStateBegan)
    {
        self.prevRotation = 0;
    }
    
    if (state == UIGestureRecognizerStateBegan
        || state == UIGestureRecognizerStateChanged)
    {
        self.totalRotation = self.totalRotation + (gr.rotation - self.prevRotation);
        self.prevRotation = gr.rotation;
        
        [self updateTransform];
        
        self.transformTouchPointInView = [gr locationOfTouch:0 inView:self];
    }
    
    [self tryNotifyTransform:state];
}

- (void)onPinch:(UIPinchGestureRecognizer *)gr
{
    UIGestureRecognizerState state = gr.state;
    if (state == UIGestureRecognizerStateBegan)
    {
        self.prevScale = 1.0;
    }
    
    if (state == UIGestureRecognizerStateBegan
        || state == UIGestureRecognizerStateChanged)
    {
        self.totalScale = MIN(MAX(self.totalScale * (gr.scale / self.prevScale), kScaleMin), kScaleMax);
        self.prevScale = gr.scale;
        
        [self updateTransform];
        
        self.transformTouchPointInView = [gr locationOfTouch:0 inView:self];
    }
    
    [self tryNotifyTransform:state];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.pan)
    {
        return (otherGestureRecognizer == self.rotation || otherGestureRecognizer == self.pinch);
    }
    else if (gestureRecognizer == self.rotation)
    {
        return (otherGestureRecognizer == self.pan || otherGestureRecognizer == self.pinch);
    }
    return NO;
}

#pragma mark - ASCWXPickerEditPluginContentProtocol

- (BOOL)hasEditedContent
{
    return YES;
}

- (void)prepareForRendering
{
    [self deactive];
}

@end
