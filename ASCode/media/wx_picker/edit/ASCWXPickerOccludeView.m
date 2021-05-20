//
//  ASCWXPickerOccludeView.m
//  ASCode
//
//  Created by Adair Wang on 2021/5/15.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerOccludeView.h"

@interface ASCWXPickerOccludeView ()

@property (nonatomic, strong) UIView *topOccludeView;
@property (nonatomic, strong) UIView *bottomOccludeView;

@end

@implementation ASCWXPickerOccludeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _occludeColor = [UIColor blackColor];
        _topOccludeHeight = 0;
        _bottomOccludeHeight = 0;
        
        _topOccludeView = [[UIView alloc] init];
        [self addSubview:_topOccludeView];
        _bottomOccludeView = [[UIView alloc] init];
        [self addSubview:_bottomOccludeView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _topOccludeView.frame = CGRectMake(0, 0, self.frame.size.width, _topOccludeHeight);
    _bottomOccludeView.frame = CGRectMake(0, self.frame.size.height - _bottomOccludeHeight, self.frame.size.width, _bottomOccludeHeight);
}

- (void)setOccludeColor:(UIColor *)occludeColor
{
    _occludeColor = occludeColor;
    _topOccludeView.backgroundColor = occludeColor;
    _bottomOccludeView.backgroundColor = occludeColor;
}

- (void)setTopOccludeHeight:(CGFloat)topOccludeHeight
{
    _topOccludeHeight = topOccludeHeight;
    
    [self setNeedsLayout];
}

- (void)setBottomOccludeHeight:(CGFloat)bottomOccludeHeight
{
    _bottomOccludeHeight = bottomOccludeHeight;
    
    [self setNeedsLayout];
}
@end
