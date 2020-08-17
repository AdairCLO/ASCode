//
//  ASCBackgroundViewPresentationController.h
//  ASCode
//
//  Created by Adair Wang on 2020/8/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef CGRect(^ASCBackgroundViewPresentationControllerGetPresentedViewFrame)(CGSize containerViewSize);

@interface ASCBackgroundViewPresentationController : UIPresentationController

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, copy) ASCBackgroundViewPresentationControllerGetPresentedViewFrame getPresentedViewFrameHandler;

@end

NS_ASSUME_NONNULL_END
