//
//  ASCWXPickerMediaAlbumModel.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/13.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerMediaAlbumModel : NSObject

- (NSUInteger)count;
- (NSString *)titleWithIndex:(NSUInteger)index;
- (NSUInteger)photoCountWithIndex:(NSUInteger)index;
- (NSString *)identifierWithIndex:(NSUInteger)index;
- (void)requestImageWithIndex:(NSUInteger)index completed:(void(^)(UIImage *image, NSString *albumIdentifier))completed;

@end

NS_ASSUME_NONNULL_END
