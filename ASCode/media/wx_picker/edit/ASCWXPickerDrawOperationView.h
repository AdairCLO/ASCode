//
//  ASCWXPickerDrawOperationView.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/6.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerDrawOperationView : UIView

@property (nonatomic, copy) void(^colorChangedHandler)(ASCWXPickerDrawOperationView *view);
@property (nonatomic, copy) void(^undoHandler)(ASCWXPickerDrawOperationView *view);

- (UIColor *)currentColor;
- (void)setEnableUndo:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
