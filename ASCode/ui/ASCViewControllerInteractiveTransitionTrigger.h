//
//  ASCViewControllerInteractiveTransitionTrigger.h
//  ASCode
//
//  Created by Adair Wang on 2020/8/15.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ASCViewControllerInteractiveTransitionTriggerGestureRecognizerType) {
    ASCViewControllerInteractiveTransitionTriggerGestureRecognizerTypeScreenEdge = 0,
    ASCViewControllerInteractiveTransitionTriggerGestureRecognizerTypePan,
};

typedef UIViewController *_Nullable(^ASCViewControllerInteractiveTransitionTriggerGetPresentVC)(CGFloat *vcWidth);
typedef UIViewController *_Nullable(^ASCViewControllerInteractiveTransitionTriggerGetDismissVC)(CGFloat *vcWidth);
typedef void(^ASCViewControllerInteractiveTransitionTriggerShowVC)(UIViewController *vc);
typedef void(^ASCViewControllerInteractiveTransitionTriggerHideVC)(UIViewController *vc);

@interface ASCViewControllerInteractiveTransitionTrigger : NSObject

@property (nonatomic, assign, readonly) ASCViewControllerInteractiveTransitionTriggerGestureRecognizerType gestureRecognizerType;

@property (nonatomic, strong, readonly) UIPercentDrivenInteractiveTransition *percentDrivenInteractiveTransition;
@property (nonatomic, assign) CGFloat percentTreshold; // default: 0.5

@property (nonatomic, assign, readonly) BOOL isLeftToRight;

@property (nonatomic, copy) ASCViewControllerInteractiveTransitionTriggerGetPresentVC getPresentVCFromLeftToRightHandler;
@property (nonatomic, copy) ASCViewControllerInteractiveTransitionTriggerGetPresentVC getPresentVCFromRightToLeftHandler;
@property (nonatomic, copy) ASCViewControllerInteractiveTransitionTriggerGetDismissVC getDismissVCFromLeftToRightHandler;
@property (nonatomic, copy) ASCViewControllerInteractiveTransitionTriggerGetDismissVC getDismissVCFromRightToLeftHandler;
@property (nonatomic, copy) ASCViewControllerInteractiveTransitionTriggerShowVC showVCHandler;
@property (nonatomic, copy) ASCViewControllerInteractiveTransitionTriggerHideVC hideVCHandler;

- (instancetype)initWithContainerView:(UIView *)containerView gestureRecognizerType:(ASCViewControllerInteractiveTransitionTriggerGestureRecognizerType)gestureRecognizerType;

@end

NS_ASSUME_NONNULL_END
