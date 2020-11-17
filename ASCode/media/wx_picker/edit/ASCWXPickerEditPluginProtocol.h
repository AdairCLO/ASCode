//
//  ASCWXPickerEditPluginProtocol.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/5.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASCWXPickerEditPluginContentProtocol <NSObject>

- (BOOL)hasEditedContent;

@end

typedef void(^ASCWXPickerEditPluginContentDidAddBlock)(UIView *content);

@protocol ASCWXPickerEditPluginProtocol <NSObject>

@property (nonatomic, copy) ASCWXPickerEditPluginContentDidAddBlock contentDidAddHandler;
@property (nonatomic, assign) CGSize contentDisplaySize;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void(^editStateChangedHandler)(BOOL isEditing);

- (CGFloat)showOperationViewInContainerView:(UIView *)containerView;;
- (void)hideOperationView;
- (void)presentOperationPageWithContainerVC:(UIViewController *)containerVC;

@end

NS_ASSUME_NONNULL_END
