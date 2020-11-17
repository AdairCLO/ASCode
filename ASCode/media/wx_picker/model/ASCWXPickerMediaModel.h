//
//  ASCWXPickerMediaModel.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/13.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerMediaModelProviding.h"

NS_ASSUME_NONNULL_BEGIN

@class AVAsset;

@interface ASCWXPickerMediaModel : NSObject <ASCWXPickerMediaModelProviding>

@property (nonatomic, copy) NSString *albumIdentifier;
@property (nonatomic, copy, readonly) NSString *albumTitle;

@end

NS_ASSUME_NONNULL_END
