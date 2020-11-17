//
//  ASCWXPickerCaptureButton.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerCaptureButton;

@protocol ASCWXPickerCaptureButtonDelegate <NSObject>

- (void)captureButtonDidCaptureImage:(ASCWXPickerCaptureButton *)button;
- (void)captureButtonDidStartCaptureVideo:(ASCWXPickerCaptureButton *)button;
- (void)captureButtonDidStopCaptureVideo:(ASCWXPickerCaptureButton *)button;
- (void)captureButtonDidCancelCaptureVideo:(ASCWXPickerCaptureButton *)button;

@end

@interface ASCWXPickerCaptureButton : UIView

@property (nonatomic, weak) id<ASCWXPickerCaptureButtonDelegate> delegate;
@property (nonatomic, assign, readonly) NSUInteger maxVideoDurationSeconds;

@end

NS_ASSUME_NONNULL_END
