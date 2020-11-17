//
//  ASCWXPickerCaptureViewController.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ASCode/ASCWXPickerCaptureResult.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerCaptureViewController;

@protocol ASCWXPickerCaptureViewControllerDelegate <NSObject>

- (void)ascWXPicerCaptureVC:(ASCWXPickerCaptureViewController *)captureVC didFinishCapturing:(nullable ASCWXPickerCaptureResult *)result;

@end

@interface ASCWXPickerCaptureViewController : UIViewController

@property (nonatomic, weak) id<ASCWXPickerCaptureViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
