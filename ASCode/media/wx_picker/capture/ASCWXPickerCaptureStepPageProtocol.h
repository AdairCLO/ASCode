//
//  ASCWXPickerCaptureStepPageProtocol.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASCWXPickerCaptureStepPageProtocol;
@class ASCWXPickerCaptureResult;

@protocol ASCWXPickerCaptureStepPageDelegate <NSObject>

- (void)captureStepPage:(id<ASCWXPickerCaptureStepPageProtocol>)page didFinishCapturing:(nullable ASCWXPickerCaptureResult *)result;

@end

@protocol ASCWXPickerCaptureStepPageProtocol <NSObject>

@property (nonatomic, weak) id<ASCWXPickerCaptureStepPageDelegate> captureStepPageDelegate;

@end

NS_ASSUME_NONNULL_END
