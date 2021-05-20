//
//  ASCWXPickerContentContainerView.h
//  ASCode
//
//  Created by Adair Wang on 2021/5/4.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerEditPluginProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerContentContainerView : UIView <ASCWXPickerEditPluginContentProtocol>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) void(^tapHandler)(ASCWXPickerContentContainerView *);
@property (nonatomic, copy) void(^transformBeganHandler)(ASCWXPickerContentContainerView *);
@property (nonatomic, copy) void(^transformMovedHandler)(ASCWXPickerContentContainerView *);
@property (nonatomic, copy) void(^transformEndedHandler)(ASCWXPickerContentContainerView *);

- (BOOL)isActive;
- (void)active:(BOOL)autoDeactive;
- (void)deactive;

- (void)resetTranslateTransform;

- (CGPoint)transformTouchPointInView;

@end

NS_ASSUME_NONNULL_END
