//
//  ASCWXPickerStepPageProtocol.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASCWXPickerStepPageProtocol;
@class ASCWXPickerResult;

@protocol ASCWXPickerStepPageDelegate <NSObject>

- (void)pickerStepPage:(id<ASCWXPickerStepPageProtocol>)page didFinishPicking:(NSArray<ASCWXPickerResult *> *)results;

@end

@protocol ASCWXPickerStepPageProtocol <NSObject>

@property (nonatomic, weak) id<ASCWXPickerStepPageDelegate> pickerStepPageDelegate;

@end

NS_ASSUME_NONNULL_END
