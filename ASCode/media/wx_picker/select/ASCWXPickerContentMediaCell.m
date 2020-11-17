//
//  ASCWXPickerContentMediaCell.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerContentMediaCell.h"
#import "ASCWXPickerCountSwitch.h"

@interface ASCWXPickerContentMediaCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ASCWXPickerCountSwitch *countSwitch;
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) UIView *disabledView;
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation ASCWXPickerContentMediaCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _disabledView = [[UIView alloc] initWithFrame:self.bounds];
        _disabledView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        _disabledView.hidden = YES;
        [self.contentView addSubview:_disabledView];
        
        _selectedView = [[UIView alloc] initWithFrame:self.bounds];
        _selectedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _selectedView.hidden = YES;
        [self.contentView addSubview:_selectedView];
        
        CGFloat countSwitchSize = 40;
        _countSwitch = [[ASCWXPickerCountSwitch alloc] initWithFrame:CGRectMake(frame.size.width - countSwitchSize, 0, countSwitchSize, countSwitchSize)];
        [_countSwitch addTarget:self action:@selector(onCountSwitchClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_countSwitch];
        
        _infoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, self.contentView.frame.size.height - 12 - 8, 20, 12)];
        _infoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _infoImageView.clipsToBounds = YES;
        [self.contentView addSubview:_infoImageView];
        
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:12];
        _infoLabel.frame = CGRectMake(CGRectGetMaxX(_infoImageView.frame) + 6, 0, self.contentView.frame.size.width - CGRectGetMaxX(_infoImageView.frame) - 6 - 6, 14.5);
        _infoLabel.center = CGPointMake(_infoLabel.center.x, _infoImageView.center.y);
        [self.contentView addSubview:_infoLabel];
    }
    return self;
}

- (NSUInteger)selectedCountNumber
{
    return self.countSwitch.count;
}

- (void)setSelectedCountNumber:(NSUInteger)selectedCountNumber
{
    [self setSelectedCountNumber:selectedCountNumber animated:NO];
}

- (void)setSelectedCountNumber:(NSUInteger)selectedCountNumber animated:(BOOL)animated
{
    [self.countSwitch setCount:selectedCountNumber animated:animated];
    self.selectedView.hidden = (selectedCountNumber == 0);
}

- (void)setDisabled:(BOOL)disabled
{
    _disabled = disabled;
    self.disabledView.hidden = !disabled;
}

- (void)onCountSwitchClicked
{
    BOOL selected = !self.countSwitch.isSelected;
    [self.delegate pickerContentMediaCell:self didSelectChanged:selected];
}

@end
