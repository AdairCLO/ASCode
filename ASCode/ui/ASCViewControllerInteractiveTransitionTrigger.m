//
//  ASCViewControllerInteractiveTransitionTrigger.m
//  ASCode
//
//  Created by Adair Wang on 2020/8/15.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCViewControllerInteractiveTransitionTrigger.h"

const CGFloat kDefaultPercentThreshold = 0.5;
const CGFloat kVelocityThreshold = 100;

@interface ASCViewControllerInteractiveTransitionTrigger ()

@property (nonatomic, assign) ASCViewControllerInteractiveTransitionTriggerGestureRecognizerType gestureRecognizerType;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenInteractiveTransition;

@property (nonatomic, assign) CGFloat presentDismissVCWidth;
@property (nonatomic, assign) BOOL isLeftToRight;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation ASCViewControllerInteractiveTransitionTrigger

- (instancetype)initWithContainerView:(UIView *)containerView gestureRecognizerType:(ASCViewControllerInteractiveTransitionTriggerGestureRecognizerType)gestureRecognizerType;
{
    self = [super init];
    if (self)
    {
        _gestureRecognizerType = gestureRecognizerType;
        
        if (_gestureRecognizerType == ASCViewControllerInteractiveTransitionTriggerGestureRecognizerTypeScreenEdge)
        {
            UIScreenEdgePanGestureRecognizer *leftGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGusture:)];
            leftGestureRecognizer.edges = UIRectEdgeLeft;
            _leftGestureRecognizer = leftGestureRecognizer;
            [containerView addGestureRecognizer:leftGestureRecognizer];

            UIScreenEdgePanGestureRecognizer *rightGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGusture:)];
            rightGestureRecognizer.edges = UIRectEdgeRight;
            _rightGestureRecognizer = rightGestureRecognizer;
            [containerView addGestureRecognizer:rightGestureRecognizer];
        }
        else if (_gestureRecognizerType == ASCViewControllerInteractiveTransitionTriggerGestureRecognizerTypePan)
        {
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGusture:)];
            _panGestureRecognizer = panGestureRecognizer;
            [containerView addGestureRecognizer:panGestureRecognizer];
        }
        
        _percentTreshold = kDefaultPercentThreshold;
    }
    return self;
}

- (void)dealloc
{
    if (_leftGestureRecognizer != nil)
    {
        [_leftGestureRecognizer.view removeGestureRecognizer:_leftGestureRecognizer];
    }
    if (_rightGestureRecognizer != nil)
    {
        [_rightGestureRecognizer.view removeGestureRecognizer:_rightGestureRecognizer];
    }
    if (_panGestureRecognizer != nil)
    {
        [_panGestureRecognizer.view removeGestureRecognizer:_panGestureRecognizer];
    }
}

- (void)handleGusture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _presentDismissVCWidth = 0;
        _isLeftToRight = NO;
        
        if (_gestureRecognizerType == ASCViewControllerInteractiveTransitionTriggerGestureRecognizerTypeScreenEdge)
        {
            _isLeftToRight = (gestureRecognizer == _leftGestureRecognizer);
        }
        else
        {
            _isLeftToRight = ([gestureRecognizer translationInView:gestureRecognizer.view].x > 0 || [gestureRecognizer velocityInView:gestureRecognizer.view].x > 0);
        }
        
        UIViewController *presentVC = nil;
        if (_isLeftToRight)
        {
            if (self.getPresentVCFromLeftToRightHandler != nil)
            {
                presentVC = self.getPresentVCFromLeftToRightHandler(&_presentDismissVCWidth);
            }
        }
        else
        {
            if (self.getPresentVCFromRightToLeftHandler != nil)
            {
                presentVC = self.getPresentVCFromRightToLeftHandler(&_presentDismissVCWidth);
            }
        }

        if (presentVC != nil)
        {
            if (self.showVCHandler != nil)
            {
                self.percentDrivenInteractiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
                // show
                self.showVCHandler(presentVC);
            }
        }
        else
        {
            UIViewController *dismissVC = nil;
            if (_isLeftToRight)
            {
                if (self.getDismissVCFromLeftToRightHandler != nil)
                {
                    dismissVC = self.getDismissVCFromRightToLeftHandler(&_presentDismissVCWidth);
                }
            }
            else
            {
                if (self.getDismissVCFromRightToLeftHandler != nil)
                {
                    dismissVC = self.getDismissVCFromRightToLeftHandler(&_presentDismissVCWidth);
                }
            }

            if (dismissVC != nil)
            {
                if (self.hideVCHandler != nil)
                {
                    self.percentDrivenInteractiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
                    // hide
                    self.hideVCHandler(dismissVC);
                }
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        if (_presentDismissVCWidth > 0)
        {
            CGFloat translationX = _isLeftToRight ? MAX(translation.x, 0) : MIN(translation.x, 0);
            CGFloat percent = MIN(ABS(translationX / _presentDismissVCWidth), 1.0);
            [self.percentDrivenInteractiveTransition updateInteractiveTransition:percent];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        BOOL finish = NO;
        
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        if (_presentDismissVCWidth > 0)
        {
            CGFloat translationX = _isLeftToRight ? MAX(translation.x, 0) : MIN(translation.x, 0);
            CGFloat percent = MIN(ABS(translationX / _presentDismissVCWidth), 1.0);
            CGFloat velocityX = [gestureRecognizer velocityInView:gestureRecognizer.view].x;
            if (percent >= _percentTreshold
                || (_isLeftToRight ? (velocityX > kVelocityThreshold) : (velocityX < -kVelocityThreshold)))
            {
                finish = YES;
                [self.percentDrivenInteractiveTransition finishInteractiveTransition];
            }
        }
        
        if (!finish)
        {
            [self.percentDrivenInteractiveTransition cancelInteractiveTransition];
        }
        
        self.percentDrivenInteractiveTransition = nil;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self.percentDrivenInteractiveTransition cancelInteractiveTransition];
        self.percentDrivenInteractiveTransition = nil;
    }
}

@end
