//
//  ASCSinglePickerView.h
//  GymTimer
//
//  Created by Adair Wang on 2020/5/27.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCSinglePickerView;

typedef void(^ASCSinglePickerViewValueChangedHandler)(ASCSinglePickerView *picker);

@interface ASCSinglePickerView : UIView

// default: 1
@property (nonatomic, assign) NSUInteger valueInterval;
// default: 0
@property (nonatomic, assign) NSUInteger minValue;
// default: 30
@property (nonatomic, assign) NSUInteger maxValue;

// default: nil
@property (nonatomic, copy) NSString *titleForSingle;
// default; nil
@property (nonatomic, copy) NSString *titleForPlural;

// default: black
@property (nonatomic, strong) UIColor *textColor;
// default: black
@property (nonatomic, strong) UIColor *splitterColor;

// default: 0
@property (nonatomic, assign) CGFloat contentMarginLeft;

@property (nonatomic, assign) NSInteger pickedValue;

@property (nonatomic, copy) ASCSinglePickerViewValueChangedHandler pickedValueChanged;

@end

NS_ASSUME_NONNULL_END
