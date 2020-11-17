//
//  ASCWXPickerCountSwitch.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// when use UIControl as super class, when used in a view which has tap gesture recognizer, the click action of this control will not be triggered!!
// and use UIButton as super class is ok.
// why: because the logic between gesture recognizer and subclasses of UIControl, https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/attaching_gesture_recognizers_to_uikit_controls
@interface ASCWXPickerCountSwitch : UIButton

@property (nonatomic, assign) NSUInteger count;

- (void)setCount:(NSUInteger)count animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
