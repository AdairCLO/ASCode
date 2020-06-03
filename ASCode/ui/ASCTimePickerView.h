//
//  ASCTimePickerView.h
//  GymTimer
//
//  Created by Adair Wang on 2020/5/27.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// TODO: columnWidth can be set
// TODO: support hour

@class ASCTimePickerView;

typedef void(^ASCTimePickerViewPickedMinuteValueChangedHandler)(ASCTimePickerView *picker);
typedef void(^ASCTimePickerViewPickedSecondValueChangedHandler)(ASCTimePickerView *picker);

@interface ASCTimePickerView : UIView

// default: 1
@property (nonatomic, assign) NSUInteger minuteInterval;
// default: 30
@property (nonatomic, assign) NSUInteger minuteMaxValue;
// default: min
@property (nonatomic, copy) NSString *minuteTitleForSingle;
// default: mins
@property (nonatomic, copy) NSString *minuteTitleForPlural;

// default: 1
@property (nonatomic, assign) NSUInteger secondInterval;
// default: 59
@property (nonatomic, assign) NSUInteger secondMaxValue;
// default: sec
@property (nonatomic, copy) NSString *secondTitleForSingle;
// default: secs
@property (nonatomic, copy) NSString *secondTitleForPlural;

// default: black
@property (nonatomic, strong) UIColor *textColor;
// default: black
@property (nonatomic, strong) UIColor *splitterColor;

// default: 0
@property (nonatomic, assign) CGFloat contentMarginLeft;

@property (nonatomic, assign) NSInteger pickedMinuteValue;
@property (nonatomic, assign) NSInteger pickedSecondValue;

@property (nonatomic, copy) ASCTimePickerViewPickedMinuteValueChangedHandler pickedMinuteValueChanged;
@property (nonatomic, copy) ASCTimePickerViewPickedSecondValueChangedHandler pickedSecondValueChanged;

@end

NS_ASSUME_NONNULL_END
