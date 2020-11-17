//
//  ASCWXPickerViewController.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ASCode/ASCWXPickerResult.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerViewController;

@protocol ASCWXPickerViewControllerDelegate <NSObject>

- (void)ascWXPicer:(ASCWXPickerViewController *)picker didFinishPicking:(NSArray<ASCWXPickerResult *> *)results;

@end

@interface ASCWXPickerViewController : UIViewController

@property (nonatomic, weak) id<ASCWXPickerViewControllerDelegate> delegate;

// TODO: [select] picker config: max image/video count; one video mode; ...

@end

NS_ASSUME_NONNULL_END
