//
//  ASCTimePickerView.m
//  GymTimer
//
//  Created by Adair Wang on 2020/5/27.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCTimePickerView.h"

static CGFloat kColumnWidth = 100;
static CGFloat kColumnHeight = 30;
static CGFloat kColumnMargin = 5;
static CGFloat kContentMargin = 5;

static NSUInteger kMinuteIntervalMin = 1;
static NSUInteger kMinuteIntervalMax = 30;
static NSUInteger kMinuteMaxValue = 30;

static NSUInteger kSecondIntervalMin = 1;
static NSUInteger kSecondIntervalMax = 30;
static NSUInteger kSecondMaxValue = 59;

@interface ASCTimePickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *minuteLabel;
@property (nonatomic, strong) UILabel *secondLabel;
@property (nonatomic, assign) BOOL delaySetSplitterColor;
@property (nonatomic, assign) CGFloat itemValueMaxWidth;
@property (nonatomic, strong) UIFont *textFont;

@end

@implementation ASCTimePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _minuteInterval = kMinuteIntervalMin;
        _minuteMaxValue = kMinuteMaxValue;
        _secondInterval = kSecondIntervalMin;
        _secondMaxValue = kSecondMaxValue;
        _minuteTitleForSingle = @"min";
        _minuteTitleForPlural = @"mins";
        _secondTitleForSingle = @"sec";
        _secondTitleForPlural = @"secs";
        _textFont = [UIFont systemFontOfSize:18];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:self.bounds];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
        
        _minuteLabel = [[UILabel alloc] init];
        _minuteLabel.font = _textFont;
        _minuteLabel.text = _minuteTitleForSingle;
        [_minuteLabel sizeToFit];
        [self addSubview:_minuteLabel];
        
        _secondLabel = [[UILabel alloc] init];
        _secondLabel.font = _textFont;
        _secondLabel.text = _secondTitleForSingle;
        [_secondLabel sizeToFit];
        [self addSubview:_secondLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL isCenter = self.frame.size.width >= (2 * kColumnWidth + kColumnMargin);
    CGFloat left = isCenter ? (self.frame.size.width - (2 * kColumnWidth + kColumnMargin)) / 2 : 0;
    _minuteLabel.frame = CGRectMake(left + self.contentMarginLeft + self.itemValueMaxWidth + kContentMargin,
                                    (self.frame.size.height - _minuteLabel.frame.size.height) / 2,
                                    _minuteLabel.frame.size.width,
                                    _minuteLabel.frame.size.height);
    
    _secondLabel.frame = CGRectMake(left + kColumnWidth + kColumnMargin + self.contentMarginLeft + self.itemValueMaxWidth + kContentMargin,
                                    (self.frame.size.height - _secondLabel.frame.size.height) / 2,
                                    _secondLabel.frame.size.width,
                                    _secondLabel.frame.size.height);
    
    if (self.delaySetSplitterColor)
    {
        self.splitterColor = _splitterColor;
    }
}

- (void)setMinuteInterval:(NSUInteger)minuteInterval
{
    if (minuteInterval < kMinuteIntervalMin || minuteInterval > kMinuteIntervalMax)
    {
        return;
    }
    
    if (minuteInterval != _minuteInterval)
    {
        _minuteInterval = minuteInterval;
        [self.pickerView reloadComponent:0];
    }
}

- (void)setMinuteMaxValue:(NSUInteger)minuteMaxValue
{
    if (minuteMaxValue > kMinuteMaxValue)
    {
        return;
    }
    
    if (minuteMaxValue != _minuteMaxValue)
    {
        _minuteMaxValue = minuteMaxValue;
        [self.pickerView reloadComponent:0];
    }
}

- (void)setSecondInterval:(NSUInteger)secondInterval
{
    if (secondInterval < kSecondIntervalMin || secondInterval > kSecondIntervalMax)
    {
        return;
    }
    
    if (secondInterval != _secondInterval)
    {
        _secondInterval = secondInterval;
        [self.pickerView reloadComponent:1];
    }
}

- (void)setSecondMaxValue:(NSUInteger)secondMaxValue
{
    if (secondMaxValue > kSecondMaxValue)
    {
        return;
    }
    
    if (secondMaxValue != _secondMaxValue)
    {
        _secondMaxValue = secondMaxValue;
        [self.pickerView reloadComponent:1];
    }
}

- (void)setMinuteTitleForSingle:(NSString *)minuteTitleForSingle
{
    _minuteTitleForSingle = minuteTitleForSingle;
    
    [self updateLabel:YES];
}

- (void)setMinuteTitleForPlural:(NSString *)minuteTitleForPlural
{
    _minuteTitleForPlural = minuteTitleForPlural;
    
    [self updateLabel:YES];
}

- (void)setSecondTitleForSingle:(NSString *)secondTitleForSingle
{
    _secondTitleForSingle = secondTitleForSingle;
    
    [self updateLabel:NO];
}

- (void)setSecondTitleForPlural:(NSString *)secondTitleForPlural
{
    _secondTitleForPlural = secondTitleForPlural;
    
    [self updateLabel:NO];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    _minuteLabel.textColor = textColor;
    _secondLabel.textColor = textColor;
    [_pickerView reloadAllComponents];
}

- (void)setSplitterColor:(UIColor *)splitterColor
{
    _splitterColor = splitterColor;
    if (self.pickerView.subviews.count == 0)
    {
        self.delaySetSplitterColor = YES;
        return;
    }
    
    self.delaySetSplitterColor = NO;
    [self.pickerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.frame.size.height < 1)
        {
            obj.backgroundColor = splitterColor;
        }
    }];
}

- (CGFloat)itemValueMaxWidth
{
    if (_itemValueMaxWidth == 0)
    {
        // '4' is the widest char
        CGRect rect = [@"44" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        options:0
                                                    attributes:@{NSFontAttributeName:_textFont}
                                                        context:nil];
        _itemValueMaxWidth = ceil(rect.size.width);
    }
    
    return _itemValueMaxWidth;
}

- (void)setContentMarginLeft:(CGFloat)contentMarginLeft
{
    if (contentMarginLeft != _contentMarginLeft)
    {
        _contentMarginLeft = contentMarginLeft;
        
        [self.pickerView reloadAllComponents];
        [self setNeedsLayout];
    }
}

- (NSInteger)pickedMinuteValue
{
    return [self.pickerView selectedRowInComponent:0] * _minuteInterval;
}

- (void)setPickedMinuteValue:(NSInteger)pickedMinuteValue
{
    NSInteger row = pickedMinuteValue / _minuteInterval;
    [self.pickerView selectRow:row inComponent:0 animated:NO];
    
    [self updateLabel:YES];
}

- (NSInteger)pickedSecondValue
{
    return [self.pickerView selectedRowInComponent:1] * _secondInterval;
}

- (void)setPickedSecondValue:(NSInteger)pickedSecondValue
{
    NSInteger row = pickedSecondValue / _secondInterval;
    [self.pickerView selectRow:row inComponent:1 animated:NO];
    
    [self updateLabel:NO];
}

- (void)updateLabel:(BOOL)isMinute
{
    NSInteger component = isMinute ? 0 : 1;
    NSUInteger count = 0;
    if (component == 0)
    {
        count = [self.pickerView selectedRowInComponent:component] * _minuteInterval;
        
        if (count > 1 && _minuteTitleForPlural.length > 0)
        {
            _minuteLabel.text = _minuteTitleForPlural;
        }
        else
        {
            _minuteLabel.text = _minuteTitleForSingle;
        }
        [_minuteLabel sizeToFit];
    }
    else if (component == 1)
    {
        count = [self.pickerView selectedRowInComponent:component] * _secondInterval;
        
        if (count > 1 && _secondTitleForPlural.length > 0)
        {
            _secondLabel.text = _secondTitleForPlural;
        }
        else
        {
            _secondLabel.text = _secondTitleForSingle;
        }
        [_secondLabel sizeToFit];
    }
}

#pragma mark -  UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    
    if (component == 0)
    {
        rows = _minuteMaxValue / _minuteInterval + 1;
    }
    else
    {
        rows = _secondMaxValue / _secondInterval + 1;
    }
        
    return rows;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    return kColumnWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    return kColumnHeight;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kColumnHeight)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.contentMarginLeft, 0, self.itemValueMaxWidth, kColumnHeight)];
        label.font = _textFont;
        label.textColor = _textColor;
        label.textAlignment = NSTextAlignmentRight;
        
        [view addSubview:label];
    }

    NSUInteger count = 0;
    if (component == 0)
    {
        count = row * _minuteInterval;
    }
    else if (component == 1)
    {
        count = row * _secondInterval;
    }
    NSString *value = [NSString stringWithFormat:@"%zd", count];
    
    UILabel *label = (UILabel *)view.subviews.firstObject;
    assert([label isKindOfClass:[UILabel class]]);
    label.text = value;
    
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    [self updateLabel:YES];
    [self updateLabel:NO];
    
    if (component == 0)
    {
        if (self.pickedMinuteValueChanged != nil)
        {
            self.pickedMinuteValueChanged(self);
        }
    }
    else if (component == 1)
    {
        if (self.pickedSecondValueChanged != nil)
        {
            self.pickedSecondValueChanged(self);
        }
    }
}

@end
