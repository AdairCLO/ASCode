//
//  ASCWXPickerDrawView.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/3.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerDrawView : UIView

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign, readonly) BOOL hasStroke;
@property (nonatomic, assign) BOOL receiveParentTouches;
@property (nonatomic, copy) void(^startStrokeHandler)(ASCWXPickerDrawView *view);
@property (nonatomic, copy) void(^endStrokeHandler)(ASCWXPickerDrawView *view);

- (void)removeLastStroke;

@end

NS_ASSUME_NONNULL_END
