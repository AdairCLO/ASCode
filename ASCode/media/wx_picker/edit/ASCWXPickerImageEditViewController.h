//
//  ASCWXPickerImageEditViewController.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerCaptureStepPageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerImageEditViewController;

@protocol ASCWXPickerImageEditViewControllerDelegate <NSObject>

- (void)imageEidtVC:(ASCWXPickerImageEditViewController *)imageEditVC didCompleteWithEditedImage:(UIImage *)editedImage;
- (void)imageEditVCWillClose:(ASCWXPickerImageEditViewController *)imageEditVC;

@end

@interface ASCWXPickerImageEditViewController : UIViewController <ASCWXPickerCaptureStepPageProtocol>

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, weak) id<ASCWXPickerImageEditViewControllerDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
