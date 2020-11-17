//
//  ASCWXPickerListMediaModel.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCWXPickerMediaModelProviding.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerListMediaModel : NSObject <ASCWXPickerMediaModelProviding>

- (instancetype)initWithMediaIdentifers:(NSArray<NSString *> *)mediaIdentifiers;

- (void)addWithMediaIdentifier:(NSString *)mediaIdentifier;
- (void)removeWithMediaIdentifier:(NSString *)mediaIdentifier;

@end

NS_ASSUME_NONNULL_END
