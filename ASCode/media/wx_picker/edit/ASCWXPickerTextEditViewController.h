//
//  ASCWXPickerTextEditViewController.h
//  ASCode
//
//  Created by Adair Wang on 2021/4/28.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerTextEditViewController;

typedef void(^ASCWXPickerTextEditViewControllerCompleteHandler)(ASCWXPickerTextEditViewController *textEditVC, BOOL isCancelled);

@interface ASCWXPickerTextEditViewController : UIViewController

@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, copy) ASCWXPickerTextEditViewControllerCompleteHandler completeHandler;

- (instancetype)initWithLabel:(nullable UILabel *)label;

@end

NS_ASSUME_NONNULL_END
