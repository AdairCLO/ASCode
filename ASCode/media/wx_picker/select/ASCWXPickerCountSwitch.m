//
//  ASCWXPickerCountSwitch.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerCountSwitch.h"
#import "ASCWXPickerColorResource.h"

static const CGFloat kMargin = 8;

@interface ASCWXPickerCountSwitch ()

@property (nonatomic, strong) CALayer *emptyLayer;
@property (nonatomic, strong) CALayer *contentLayer;
@property (nonatomic, strong) CATextLayer *countLayer;

@end

@implementation ASCWXPickerCountSwitch

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        CGRect emptyLayerFrame = CGRectMake(kMargin, kMargin, frame.size.width - kMargin - kMargin, frame.size.height - kMargin - kMargin);
        _emptyLayer = [self buildEmptyLayerWithFrame:emptyLayerFrame];
        [self.layer addSublayer:_emptyLayer];
        
        _contentLayer = [CALayer layer];
        _contentLayer.frame = _emptyLayer.frame;
        _contentLayer.backgroundColor = [ASCWXPickerColorResource themeColor].CGColor;
        _contentLayer.cornerRadius = _contentLayer.frame.size.width / 2;
        [self.layer addSublayer:_contentLayer];
        
        _countLayer = [CATextLayer layer];
        _countLayer.fontSize = 16;
        _countLayer.string = @"";
        _countLayer.alignmentMode = kCAAlignmentCenter;
        _countLayer.foregroundColor = [UIColor whiteColor].CGColor;
        [_contentLayer addSublayer:_countLayer];
        
        _contentLayer.hidden = YES;
    }
    return self;
}

- (void)setCount:(NSUInteger)count
{
    [self setCount:count animated:NO];
}

- (void)setCount:(NSUInteger)count animated:(BOOL)animated
{
    if (_count == count)
    {
        return;
    }
    _count = count;
    [self updateState:animated];
}

- (BOOL)isSelected
{
    return self.count > 0;
}

- (void)updateState:(BOOL)animated
{
    if (self.count > 0)
    {
        BOOL needShowAnimation = NO;
        if (animated && [_countLayer.string isKindOfClass:[NSString class]])
        {
            needShowAnimation = ((NSString *)_countLayer.string).length == 0;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        _emptyLayer.hidden = YES;
        _contentLayer.hidden = NO;
        [self updateCount];
        
        [CATransaction commit];
        
        if (needShowAnimation)
        {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            animation.keyTimes = @[ @(0), @(0.4), @(0.8), @(1)];
            animation.values = @[
                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6, 0.6, 1)],
                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1)],
                [NSValue valueWithCATransform3D:CATransform3DIdentity],
            ];
            animation.duration = 0.35;
            [_contentLayer addAnimation:animation forKey:@"select"];
        }
    }
    else
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        _emptyLayer.hidden = NO;
        _contentLayer.hidden = YES;
        [self updateCount];
        
        [CATransaction commit];
    }
}

- (void)updateCount
{
    _countLayer.string = [NSString stringWithFormat:@"%@", self.count > 0 ? @(self.count) : @""];
    CGSize size = _countLayer.preferredFrameSize;
    _countLayer.frame = CGRectMake((_contentLayer.frame.size.width - size.width) / 2,
                                   (_contentLayer.frame.size.height - size.height) / 2,
                                   size.width,
                                   size.height);
}

#pragma mark - protected

- (CALayer *)buildEmptyLayerWithFrame:(CGRect)frame
{
    CALayer *emptyLayer = [CALayer layer];
    emptyLayer.frame = frame;
    emptyLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    emptyLayer.cornerRadius = frame.size.width / 2;
    emptyLayer.borderColor = [UIColor whiteColor].CGColor;
    emptyLayer.borderWidth = 1;
    
    return emptyLayer;
}

@end
