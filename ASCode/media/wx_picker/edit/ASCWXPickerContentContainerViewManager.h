//
//  ASCWXPickerContentContainerViewManager.h
//  ASCode
//
//  Created by Adair Wang on 2021/5/10.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerContentContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerContentContainerViewManager : NSObject

- (instancetype)initWithParentView:(UIView *)parentView;

- (void)putViewToTop:(ASCWXPickerContentContainerView *)view;
- (void)activeView:(ASCWXPickerContentContainerView *)view autoDeactive:(BOOL)autoDeactive;

@end

NS_ASSUME_NONNULL_END
