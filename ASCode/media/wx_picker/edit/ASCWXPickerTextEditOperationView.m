//
//  ASCWXPickerTextEditOperationView.m
//  ASCode
//
//  Created by Adair Wang on 2021/4/29.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerTextEditOperationView.h"
#import "ASCWXPickerImageResource.h"

static const CGFloat kMargin = 16;
static const CGFloat kSelectedColorViewSize = 24;
static const CGFloat kSelectedColorViewContentSize = 16;
static const CGFloat kUnselectedColorViewSize = 18;
static const CGFloat kUnselectedColorViewContentSize = 14;
static const NSUInteger kDefaultSelectedIndex = 2;

static const NSInteger kColorViewTag = 101;
static const NSInteger kColorViewContentViewTag = 102;

@interface ASCWXPickerTextEditOperationView ()

@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, strong) NSArray<UIButton *> *colorButtons;
@property (nonatomic, strong) UIButton *colorModeButton;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation ASCWXPickerTextEditOperationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _colors = @[
            [UIColor colorWithRed:249/255.0 green:248/255.0 blue:249/255.0 alpha:1.0],
            [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1.0],
            [UIColor colorWithRed:250/255.0 green:80/255.0 blue:81/255.0 alpha:1.0],
            [UIColor colorWithRed:255/255.0 green:195/255.0 blue:0/255.0 alpha:1.0],
            [UIColor colorWithRed:4/255.0 green:193/255.0 blue:96/255.0 alpha:1.0],
            [UIColor colorWithRed:20/255.0 green:173/255.0 blue:255/255.0 alpha:1.0],
            [UIColor colorWithRed:100/255.0 green:102/255.0 blue:239/255.0 alpha:1.0],
        ];
        
        NSMutableArray *colorButtons = [[NSMutableArray alloc] init];
        [_colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIButton *btn = [[UIButton alloc] init];
            [btn addTarget:self action:@selector(onColorBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *v = [[self class] colorViewWithColor:c];
            [btn addSubview:v];
            [self addSubview:btn];
            
            [colorButtons addObject:btn];
        }];
        _colorButtons = colorButtons;
        
        _colorModeButton = [[UIButton alloc] init];
        _colorModeButton.selected = NO;
        [_colorModeButton setImage:[ASCWXPickerImageResource textFgColorMode] forState:UIControlStateNormal];
        [_colorModeButton setImage:[ASCWXPickerImageResource textBgColorMode] forState:UIControlStateSelected];
        [_colorModeButton addTarget:self action:@selector(onColorModeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_colorModeButton];
        
        _selectedIndex = kDefaultSelectedIndex;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    CGFloat width = 0;
    if (frame.size.width > 0)
    {
        width = floor((frame.size.width - kMargin - kMargin) / (self.colorButtons.count + 1));
    }
    CGFloat btnSize = MIN(width, frame.size.height);
    
    [self updateColorButtonStateWithBtnSize:btnSize];
    
    _colorModeButton.frame = CGRectMake(kMargin, (frame.size.height - btnSize) / 2, btnSize, btnSize);
}

- (UIColor *)currentColor
{
    return [_colors objectAtIndex:self.selectedIndex];
}

- (BOOL)isBackgroundColorMode
{
    return self.colorModeButton.selected;
}

- (void)updateColor:(UIColor *)color isBackgroundColorMode:(BOOL)isBackgroundColorMode
{
    __block NSInteger selectedIndex = -1;
    const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);
    if (colorComponents != nil)
    {
        [self.colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            const CGFloat *cc = CGColorGetComponents(obj.CGColor);
            if (cc != nil && cc[0] == colorComponents[0] && cc[1] == colorComponents[1] && cc[2] == colorComponents[2])
            {
                selectedIndex = idx;
                *stop = YES;
            }
        }];
    }
    if (selectedIndex >= 0 && selectedIndex < self.colors.count)
    {
        _selectedIndex = selectedIndex;
        [self updateColorButtonStateWithBtnSize:self.colorButtons.firstObject.frame.size.width];
    }
    
    _colorModeButton.selected = isBackgroundColorMode;
}

- (void)onColorBtnClicked:(UIButton *)btn
{
    NSUInteger index = [self.colorButtons indexOfObject:btn];
    if (index == self.selectedIndex)
    {
        return;
    }
    
    self.selectedIndex = index;
    if (self.colorChangedHandler != nil)
    {
        self.colorChangedHandler(self);
    }
    
    [self updateColorButtonStateWithBtnSize:self.colorButtons.firstObject.frame.size.width];
}

- (void)onColorModeBtnClicked
{
    self.colorModeButton.selected = !self.colorModeButton.selected;
    
    if (self.colorModeChangedHandler != nil)
    {
        self.colorModeChangedHandler(self);
    }
}

- (void)updateColorButtonStateWithBtnSize:(CGFloat)btnSize
{
    CGRect frame = self.frame;
    [self.colorButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull btn, NSUInteger idx, BOOL * _Nonnull stop) {
        btn.frame = CGRectMake(kMargin + (idx + 1) * btnSize, (frame.size.height - btnSize) / 2, btnSize, btnSize);
        
        UIView *colorView = [btn viewWithTag:kColorViewTag];
        if (colorView != nil)
        {
            BOOL isSelected = (idx == self.selectedIndex);
            CGFloat backgroundSize = (isSelected ? kSelectedColorViewSize : kUnselectedColorViewSize);
            CGFloat contentSize = (isSelected ? kSelectedColorViewContentSize : kUnselectedColorViewContentSize);
            
            colorView.frame = CGRectMake((btnSize - backgroundSize) / 2,
                                         (btnSize - backgroundSize) / 2,
                                         backgroundSize,
                                         backgroundSize);
            colorView.layer.cornerRadius = backgroundSize / 2;
            
            UIView *contentView = [colorView viewWithTag:kColorViewContentViewTag];
            contentView.frame = CGRectMake((backgroundSize - contentSize) / 2,
                                           (backgroundSize - contentSize) / 2,
                                           contentSize,
                                           contentSize);
            contentView.layer.cornerRadius = contentSize / 2;
        }
    }];
}

+ (UIView *)colorViewWithColor:(UIColor *)color
{
    UIView *colorView = [[UIView alloc] init];
    colorView.backgroundColor = [UIColor whiteColor];
    colorView.userInteractionEnabled = NO;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = color;
    contentView.tag = kColorViewContentViewTag;
    [colorView addSubview:contentView];
    
    colorView.tag = kColorViewTag;
    
    return colorView;
}

@end
