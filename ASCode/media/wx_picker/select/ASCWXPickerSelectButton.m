//
//  ASCWXPickerSelectButton.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerSelectButton.h"

static const CGFloat kHeight = 32;
static const CGFloat kContentMargin = 4;
static const CGFloat kIndicatorViewSize = 18;
static const CGFloat kArrawWidth = 10;
static const CGFloat kArrawHeight = 5;

@interface ASCWXPickerSelectButton ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end

@implementation ASCWXPickerSelectButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, kHeight)];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIndicatorViewSize, kIndicatorViewSize)];
        _indicatorView.layer.cornerRadius = kIndicatorViewSize / 2;
        _indicatorView.backgroundColor = [UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0];
        _indicatorView.userInteractionEnabled = NO;
        [self addSubview:_indicatorView];
        
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.frame = CGRectMake((_indicatorView.frame.size.width - kArrawWidth) / 2, (_indicatorView.frame.size.height - kArrawHeight) / 2, kArrawWidth, kArrawHeight);
        _arrowLayer.fillColor = nil;
        _arrowLayer.strokeColor = [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1.0].CGColor;
        _arrowLayer.lineWidth = 2;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(kArrawWidth / 2, kArrawHeight)];
        [path addLineToPoint:CGPointMake(kArrawWidth, 0)];
        _arrowLayer.path = path.CGPath;
        [_indicatorView.layer addSublayer:_arrowLayer];
        
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 6);
        self.backgroundColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1.0];
        
        self.layer.cornerRadius = kHeight / 2;
        // ...
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)updateSize
{
    [self.titleLabel sizeToFit];
    
    CGFloat newWidth = self.contentEdgeInsets.left + self.titleLabel.frame.size.width + kContentMargin + self.indicatorView.frame.size.width + self.contentEdgeInsets.right;
    CGFloat diffWidth = newWidth - self.frame.size.width;
    CGRect newFrame = CGRectMake(self.frame.origin.x - diffWidth / 2,
                                 self.frame.origin.y,
                                 newWidth,
                                 kHeight);
    
    CGRect indicatorViewNewFrame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + kContentMargin, (self.frame.size.height - self.indicatorView.frame.size.height) / 2, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.frame = newFrame;
        self.indicatorView.frame = indicatorViewNewFrame;
    } completion:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(self.contentEdgeInsets.left, (self.frame.size.height - self.titleLabel.frame.size.height) / 2, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    self.indicatorView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + kContentMargin, (self.frame.size.height - self.indicatorView.frame.size.height) / 2, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
}

- (void)sizeToFit
{
    [self.titleLabel sizeToFit];
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.contentEdgeInsets.left + self.titleLabel.frame.size.width + kContentMargin + self.indicatorView.frame.size.width + self.contentEdgeInsets.right,
                            kHeight);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.arrowLayer.transform = CATransform3DRotate(self.arrowLayer.transform, M_PI - 0.000001, 0, 0, 1);
}

@end
