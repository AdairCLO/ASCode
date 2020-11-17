//
//  ASCWXPickerMediaModelProviding.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@class AVAsset;

@protocol ASCWXPickerMediaModelProviding <NSObject>

@property (nonatomic, strong) NSDictionary<NSString *, UIImage *> *editedImageData;

- (NSUInteger)count;
- (NSString *)identifierWithIndex:(NSUInteger)index;
- (NSUInteger)indexWithIdentifier:(NSString *)identifier;
- (BOOL)isVideoWithIndex:(NSUInteger)index;
- (BOOL)isEditedWithIndex:(NSUInteger)index;
- (NSTimeInterval)durationWithIndex:(NSUInteger)index;
- (void)requestImageWithIndex:(NSUInteger)index size:(CGSize)size completed:(void(^)(UIImage *image, NSString *mediaIdentifier))completed;
- (void)requestVideoWithIndex:(NSUInteger)index completed:(void(^)(AVAsset *videoAsset, NSString *mediaIdentifier))completed;

@end

NS_ASSUME_NONNULL_END
