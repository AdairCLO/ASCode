//
//  ASCWXPickerResult.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerResult : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) AVAsset *videoAsset;

@end

NS_ASSUME_NONNULL_END
