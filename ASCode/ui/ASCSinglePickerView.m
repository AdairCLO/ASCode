//
//  ASCSinglePickerView.m
//  GymTimer
//
//  Created by Adair Wang on 2020/5/27.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCSinglePickerView.h"

static CGFloat kColumnHeight = 30;
static CGFloat kContentMargin = 5;

@interface ASCSinglePickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL delaySetSplitterColor;
@property (nonatomic, assign) CGFloat itemValueMaxWidth;
@property (nonatomic, strong) UIFont *textFont;

@end

@implementation ASCSinglePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _valueInterval = 1;
        _minValue = 0;
        _maxValue = 30;
        _textColor = [UIColor blackColor];
        _textFont = [UIFont systemFontOfSize:18];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:self.bounds];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
        
        _label = [[UILabel alloc] init];
        _label.font = _textFont;
        _label.textColor = _textColor;
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = CGRectMake(self.contentMarginLeft + self.itemValueMaxWidth + kContentMargin,
                              (self.frame.size.height - _label.frame.size.height) / 2,
                              _label.frame.size.width,
                              _label.frame.size.height);
    
    if (self.delaySetSplitterColor)
    {
        self.splitterColor = _splitterColor;
    }
}

- (void)setValueInterval:(NSUInteger)valueInterval
{
    if (valueInterval <= 0)
    {
        return;
    }
    
    if (valueInterval != _valueInterval)
    {
        _valueInterval = valueInterval;
        [self.pickerView reloadComponent:0];
        
        [self updateLabel];
    }
}

- (void)setMinValue:(NSUInteger)minValue
{
    if (minValue > _maxValue)
    {
        return;
    }
    
    if (minValue != _minValue)
    {
        _minValue = minValue;
        [self.pickerView reloadComponent:0];
        
        [self updateLabel];
    }
}

- (void)setMaxValue:(NSUInteger)maxValue
{
    if (maxValue < _minValue)
    {
        return;
    }
    
    if (maxValue != _maxValue)
    {
        _maxValue = maxValue;
        [self.pickerView reloadComponent:0];
        
        _itemValueMaxWidth = 0;
        [self setNeedsLayout];
        
        [self updateLabel];
    }
}

- (void)setTitleForSingle:(NSString *)titleForSingle
{
    _titleForSingle = titleForSingle;
    
    [self updateLabel];
}

- (void)setTitleForPlural:(NSString *)titleForPlural
{
    _titleForPlural = titleForPlural;
    
    [self updateLabel];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    _label.textColor = textColor;
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
        NSMutableString *maxValueString = [[NSMutableString alloc] init];
        NSUInteger v = _maxValue;
        while (v > 0)
        {
            // '4' is the widest char
            [maxValueString appendString:@"4"];
            
            v = floor(v / 10);
        }
        CGRect rect = [maxValueString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
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

- (NSInteger)pickedValue
{
    return [self.pickerView selectedRowInComponent:0] * _valueInterval + _minValue;
}

- (void)setPickedValue:(NSInteger)pickedValue
{
    NSInteger row = (pickedValue - _minValue) / _valueInterval;
    [self.pickerView selectRow:row inComponent:0 animated:NO];
    
    [self updateLabel];
}

- (void)updateLabel
{
    NSInteger currentValue = [self.pickerView selectedRowInComponent:0] * _valueInterval + _minValue;
    if (currentValue > 1 && _titleForPlural.length > 0)
    {
        _label.text = _titleForPlural;
    }
    else
    {
        _label.text = _titleForSingle;
    }
    [_label sizeToFit];
}

#pragma mark -  UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = (_maxValue - _minValue) / _valueInterval + 1;
    return rows;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    return self.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    return kColumnHeight;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kColumnHeight)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.contentMarginLeft, 0, self.itemValueMaxWidth, kColumnHeight)];
        label.font = _textFont;
        label.textColor = _textColor;
        label.textAlignment = NSTextAlignmentRight;
        
        [view addSubview:label];
    }

    NSUInteger count = row * _valueInterval + _minValue;
    NSString *value = [NSString stringWithFormat:@"%zd", count];
    
    UILabel *label = (UILabel *)view.subviews.firstObject;
    assert([label isKindOfClass:[UILabel class]]);
    label.text = value;
    
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    [self updateLabel];
    
    if (self.pickedValueChanged != nil)
    {
        self.pickedValueChanged(self);
    }
}

@end
