//
//  ASCWXPickerBottomBarView.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerBottomBarView.h"

const static CGFloat kDefaultBottomBarContentHeight = 56;
const static CGFloat kMargin = 16;

@interface ASCWXPickerBottomBarView ()

@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation ASCWXPickerBottomBarView

- (instancetype)init
{
    return [self initWithContentHeight:kDefaultBottomBarContentHeight];
}

- (instancetype)initWithContentHeight:(CGFloat)contentHeight
{
    CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - contentHeight, [UIScreen mainScreen].bounds.size.width, contentHeight);
    self = [super initWithFrame:frame];
    if (self)
    {
        _contentHeight = contentHeight;
        
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:effect];
        v.frame = self.bounds;
        _backgroundView = v;
        [self addSubview:_backgroundView];
    }
    return self;
}

- (void)safeAreaInsetsDidChange
{
    [self updateFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat top = self.topView.frame.size.height;
    
    self.leftView.frame = CGRectMake(kMargin,
                                     top + (self.contentHeight - self.leftView.frame.size.height) / 2,
                                     self.leftView.frame.size.width,
                                     self.leftView.frame.size.height);
    
    self.centerView.frame = CGRectMake((self.frame.size.width - self.centerView.frame.size.width) / 2,
                                       top + (self.contentHeight - self.centerView.frame.size.height) / 2,
                                       self.centerView.frame.size.width,
                                       self.centerView.frame.size.height);
    
    self.rightView.frame = CGRectMake(self.frame.size.width - kMargin - self.rightView.frame.size.width,
                                      top + (self.contentHeight - self.rightView.frame.size.height) / 2,
                                      self.rightView.frame.size.width,
                                      self.rightView.frame.size.height);
}

- (void)setLeftView:(UIView *)leftView
{
    if (_leftView != leftView)
    {
        [_leftView removeFromSuperview];
        if (leftView != nil)
        {
            [self addSubview:leftView];
        }
        _leftView = leftView;
    }
    
    [self setNeedsLayout];
}

- (void)setCenterView:(UIView *)centerView
{
    if (_centerView != centerView)
    {
        [_centerView removeFromSuperview];
        if (centerView != nil)
        {
            [self addSubview:centerView];
        }
        _centerView = centerView;
    }
    
    [self setNeedsLayout];
}

- (void)setRightView:(UIView *)rightView
{
    if (_rightView != rightView)
    {
        [_rightView removeFromSuperview];
        if (rightView != nil)
        {
            [self addSubview:rightView];
        }
        _rightView = rightView;
    }
    
    [self setNeedsLayout];
}

- (void)setTopView:(UIView *)topView
{
    if (_topView != topView)
    {
        [_topView removeFromSuperview];
        if (topView != nil)
        {
            [self addSubview:topView];
        }
        _topView = topView;
    }
    
    [self updateFrame];
    
    [self setNeedsLayout];
}

- (BOOL)translucent
{
    return !self.backgroundView.hidden;
}

- (void)setTranslucent:(BOOL)translucent
{
    self.backgroundView.hidden = !translucent;
}

- (void)showBarView:(BOOL)animated
{
    if (self.alpha == 1)
    {
        return;
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 1;
        } completion:nil];
    }
    else
    {
        self.alpha = 1;
    }
}

- (void)hideBarView:(BOOL)animated
{
    if (self.alpha == 0)
    {
        return;
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
        } completion:nil];
    }
    else
    {
        self.alpha = 0;
    }
}

- (void)toggleShowHideBarView:(BOOL)animated
{
    if (self.alpha == 0)
    {
        [self showBarView:animated];
    }
    else
    {
        [self hideBarView:animated];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self && self.backgroundView.hidden)
    {
        return nil;
    }
    // TODO: image edit's draw eidt: draw from bottom bar, the touches will be receviced by bottom bar's subviews....
    return v;
}

- (void)updateFrame
{
    CGFloat safeAreaInsetsBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetsBottom = self.safeAreaInsets.bottom;
    }
    CGFloat height = safeAreaInsetsBottom + self.contentHeight + self.topView.frame.size.height;
    self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - height, [UIScreen mainScreen].bounds.size.width, height);
    self.backgroundView.frame = self.bounds;
}

@end
