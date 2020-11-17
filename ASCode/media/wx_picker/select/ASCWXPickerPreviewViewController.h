//
//  ASCWXPickerPreviewViewController.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerStepPageProtocol.h"
#import "ASCWXPickerMediaModelProviding.h"

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerSelectedMediaData;
@class ASCWXPickerMediaModel;
@class ASCWXPickerPreviewViewController;

@protocol ASCWXPickerPreviewViewControllerDelegate <NSObject>

- (void)previewViewControllerWillBack:(ASCWXPickerPreviewViewController *)previewVC;

@end

@interface ASCWXPickerPreviewViewController : UIViewController <ASCWXPickerStepPageProtocol>

- (instancetype)initWithMediaModel:(id<ASCWXPickerMediaModelProviding>)mediaModel selectedMediaData:(ASCWXPickerSelectedMediaData *)selectedMediaData isInsertMode:(BOOL)isInsertMode;
- (instancetype)initWithMediaModel:(id<ASCWXPickerMediaModelProviding>)mediaModel selectedMediaData:(ASCWXPickerSelectedMediaData *)selectedMediaData isInsertMode:(BOOL)isInsertMode firstDisplayIndex:(NSUInteger)firstDisplayIndex;

@property (nonatomic, weak) id<ASCWXPickerPreviewViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) ASCWXPickerSelectedMediaData *selectedMediaData;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, UIImage *> *editedImageData;

@end

NS_ASSUME_NONNULL_END
