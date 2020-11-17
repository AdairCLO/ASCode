//
//  ASCWXPickerImageResource.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerImageResource : NSObject

+ (UIImage *)defaultMediaImage;
+ (UIImage *)playbackImage;
+ (UIImage *)videoImage;
+ (UIImage *)imageImage;

// camera
+ (UIImage *)cameraSwitchImage;
+ (UIImage *)cameraCancelImage;

// bar
+ (UIImage *)backImage;

// edit
+ (UIImage *)imageEditDrawImage;
+ (UIImage *)imageEditSelectedDrawImage;
+ (UIImage *)imageEditEmojiImage;
+ (UIImage *)imageEditTextImage;
+ (UIImage *)imageEditCropImage;
+ (UIImage *)imageEditMosaicImage;
+ (UIImage *)imageEditSelectedMosaicImage;
+ (UIImage *)videoEditEmojiImage;
+ (UIImage *)videoEditTextImage;
+ (UIImage *)videoEditAudioImage;
+ (UIImage *)videoEditClipImage;
// edit operation view
+ (UIImage *)undoImage;

@end

NS_ASSUME_NONNULL_END
