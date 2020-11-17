//
//  ASCWXPickerInterfaceOrientationManager.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/24.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ASCWXPickerInterfaceOrientationManagerOrientationDidChangeNotification;

@interface ASCWXPickerInterfaceOrientationManager : NSObject

@property (nonatomic, assign, readonly) UIInterfaceOrientation currentOrientation;

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation;

- (void)startUpdate;
- (void)stopUpdate;

@end

NS_ASSUME_NONNULL_END
