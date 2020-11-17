//
//  ASCWXPickerTopBarView.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerTopBarView.h"

const static CGFloat kDefaultTopBarContentHeight = 44;
const static CGFloat kMargin = 16;

@interface ASCWXPickerTopBarView ()

@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation ASCWXPickerTopBarView

- (instancetype)init
{
    return [self initWithContentHeight:kDefaultTopBarContentHeight];
}

- (instancetype)initWithContentHeight:(CGFloat)contentHeight
{
    CGFloat top = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat height = top + contentHeight;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height);
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
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.contentHeight + self.safeAreaInsets.top);
    _backgroundView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftView.frame = CGRectMake(kMargin,
                                     self.frame.size.height - self.contentHeight + (self.contentHeight - self.leftView.frame.size.height) / 2,
                                     self.leftView.frame.size.width,
                                     self.leftView.frame.size.height);
    
    self.centerView.frame = CGRectMake((self.frame.size.width - self.centerView.frame.size.width) / 2,
                                       self.frame.size.height - self.contentHeight + (self.contentHeight - self.centerView.frame.size.height) / 2,
                                       self.centerView.frame.size.width,
                                       self.centerView.frame.size.height);
    
    self.rightView.frame = CGRectMake(self.frame.size.width - kMargin - self.rightView.frame.size.width,
                                      self.frame.size.height - self.contentHeight + (self.contentHeight - self.rightView.frame.size.height) / 2,
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
    return v;
}

@end
