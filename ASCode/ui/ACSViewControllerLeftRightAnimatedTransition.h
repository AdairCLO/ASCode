//
//  ACSViewControllerLeftRightAnimatedTransition.h
//  ASCode
//
//  Created by Adair Wang on 2020/8/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACSViewControllerLeftRightAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isLeftToRight;
@property (nonatomic, assign) BOOL isDismiss;
@property (nonatomic, assign) NSTimeInterval animatedDuration; // default 0.3sec

@end

NS_ASSUME_NONNULL_END
