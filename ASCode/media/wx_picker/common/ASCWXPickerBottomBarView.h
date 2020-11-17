//
//  ASCWXPickerBottomBarView.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerBottomBarView : UIView

@property (nonatomic, strong, nullable) UIView *leftView;
@property (nonatomic, strong, nullable) UIView *centerView;
@property (nonatomic, strong, nullable) UIView *rightView;
@property (nonatomic, strong, nullable) UIView *topView;

@property (nonatomic, assign) BOOL translucent;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

- (instancetype)initWithContentHeight:(CGFloat)contentHeight;

- (void)showBarView:(BOOL)animated;
- (void)hideBarView:(BOOL)animated;
- (void)toggleShowHideBarView:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
