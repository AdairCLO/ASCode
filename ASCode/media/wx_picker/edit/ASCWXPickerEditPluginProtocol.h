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
- (void)prepareForRendering;

@end

typedef void(^ASCWXPickerEditPluginContentDidAddBlock)(UIView *content);
typedef void(^ASCWXPickerEditPluginContentDidRemoveBlock)(UIView *content);
typedef void(^ASCWXPickerEditPluginContentDidUpdateBlock)(UIView *content);

@protocol ASCWXPickerEditPluginProtocol <NSObject>

@property (nonatomic, copy) ASCWXPickerEditPluginContentDidAddBlock contentDidAddHandler;
@property (nonatomic, copy) ASCWXPickerEditPluginContentDidRemoveBlock contentDidRemoveHandler;
@property (nonatomic, copy) ASCWXPickerEditPluginContentDidUpdateBlock contentDidUpdateHandler;
@property (nonatomic, assign) CGSize contentDisplaySize;
@property (nonatomic, copy) void(^editStateChangedHandler)(BOOL isEditing);

- (CGFloat)showOperationViewInContainerView:(UIView *)containerView;
- (void)hideOperationView;
- (void)presentOperationPageWithContainerVC:(UIViewController *)containerVC withContentView:(nullable UIView *)contentView;

@end

NS_ASSUME_NONNULL_END
