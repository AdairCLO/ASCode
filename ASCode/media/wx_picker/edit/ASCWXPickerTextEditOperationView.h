//
//  ASCWXPickerTextEditOperationView.h
//  ASCode
//
//  Created by Adair Wang on 2021/4/29.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerTextEditOperationView : UIView

@property (nonatomic, copy) void(^colorChangedHandler)(ASCWXPickerTextEditOperationView *view);
@property (nonatomic, copy) void(^colorModeChangedHandler)(ASCWXPickerTextEditOperationView *view);

- (UIColor *)currentColor;
- (BOOL)isBackgroundColorMode;
- (void)updateColor:(UIColor *)color isBackgroundColorMode:(BOOL)isBackgroundColorMode;

@end

NS_ASSUME_NONNULL_END
