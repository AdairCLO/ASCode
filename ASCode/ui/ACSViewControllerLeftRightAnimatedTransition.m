//
//  ACSViewControllerLeftRightAnimatedTransition.m
//  ASCode
//
//  Created by Adair Wang on 2020/8/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ACSViewControllerLeftRightAnimatedTransition.h"

const NSTimeInterval kDefaultTransitionDuration = 0.3;

@interface ACSViewControllerLeftRightAnimatedTransition ()

@end

@implementation ACSViewControllerLeftRightAnimatedTransition

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _animatedDuration = kDefaultTransitionDuration;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext
{
    return _animatedDuration;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = transitionContext.containerView;
    UIViewAnimationOptions animationOption = transitionContext.interactive ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseOut; // UIViewAnimationCurveEaseOut
    
    if (!self.isDismiss)
    {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        [containerView addSubview:toView];
        
        CGRect initFrame = CGRectZero;
        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
        if (self.isLeftToRight)
        {
            initFrame = CGRectMake(-finalFrame.size.width, finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
        }
        else
        {
            initFrame = CGRectMake(containerView.frame.size.width, finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
        }
        
        toView.frame = initFrame;
        [UIView animateWithDuration:self.animatedDuration delay:0 options:animationOption animations:^{
            toView.frame = finalFrame;
        } completion:^(BOOL finished) {
            BOOL transitionOK = finished && !transitionContext.transitionWasCancelled;
            [transitionContext completeTransition:transitionOK];
        }];
    }
    else
    {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        
        CGRect initFrame = [transitionContext initialFrameForViewController:fromVC];;
        CGRect finalFrame = CGRectZero;
        if (self.isLeftToRight)
        {
            finalFrame = CGRectMake(containerView.frame.size.width, initFrame.origin.y, initFrame.size.width, initFrame.size.height);
        }
        else
        {
            finalFrame = CGRectMake(-initFrame.size.width, initFrame.origin.y, initFrame.size.width, initFrame.size.height);
        }
        
        fromView.frame = initFrame;
        [UIView animateWithDuration:self.animatedDuration delay:0 options:animationOption animations:^{
            fromView.frame = finalFrame;
        } completion:^(BOOL finished) {
            BOOL transitionOK = finished && !transitionContext.transitionWasCancelled;
            [transitionContext completeTransition:transitionOK];
        }];
    }
}

///// A conforming object implements this method if the transition it creates can
///// be interrupted. For example, it could return an instance of a
///// UIViewPropertyAnimator. It is expected that this method will return the same
///// instance for the life of a transition.
//- (id<UIViewImplicitlyAnimating>)interruptibleAnimatorForTransition:(id<UIViewControllerContextTransitioning>)transitionContext API_AVAILABLE(ios(10.0))
//{
//    return nil;
//}

//// This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
//- (void)animationEnded:(BOOL)transitionCompleted
//{
//
//}

@end
