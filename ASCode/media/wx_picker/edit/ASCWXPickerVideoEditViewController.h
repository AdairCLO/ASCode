//
//  ASCWXPickerVideoEditViewController.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerCaptureStepPageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerVideoEditViewController : UIViewController <ASCWXPickerCaptureStepPageProtocol>

@property (nonatomic, strong) NSURL *videoURL;

@end

NS_ASSUME_NONNULL_END
