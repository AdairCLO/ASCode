//
//  ASCBackgroundViewPresentationController.m
//  ASCode
//
//  Created by Adair Wang on 2020/8/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCBackgroundViewPresentationController.h"

@interface ASCBackgroundViewPresentationController ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation ASCBackgroundViewPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackgroundView)];
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [_backgroundView addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (UIColor *)backgroundColor
{
    return _backgroundView.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundView.backgroundColor = backgroundColor;
}

- (void)onTapBackgroundView
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - override

- (void)containerViewWillLayoutSubviews
{
    _backgroundView.frame = self.containerView.bounds;
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGRect presentedViewFrame = self.containerView.bounds;
    
    if (self.getPresentedViewFrameHandler != nil)
    {
        presentedViewFrame = self.getPresentedViewFrameHandler(self.containerView.bounds.size);
    }
    
    return presentedViewFrame;
}

- (void)presentationTransitionWillBegin
{
    [self.containerView insertSubview:_backgroundView atIndex:0];
    
    self.backgroundView.alpha = 0;
    id<UIViewControllerTransitionCoordinator> transitionCoorinator = self.presentedViewController.transitionCoordinator;
    if (transitionCoorinator != nil)
    {
        [transitionCoorinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.backgroundView.alpha = 1;
        } completion:nil];
    }
    else
    {
        self.backgroundView.alpha = 1;
    }
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (!completed)
    {
        [self.backgroundView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin
{
    self.backgroundView.alpha = 1;
    id<UIViewControllerTransitionCoordinator> transitionCoorinator = self.presentedViewController.transitionCoordinator;
    if (transitionCoorinator != nil)
    {
        [transitionCoorinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.backgroundView.alpha = 0;
        } completion:nil];
    }
    else
    {
        self.backgroundView.alpha = 0;
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed)
    {
        [self.backgroundView removeFromSuperview];
    }
}

@end
