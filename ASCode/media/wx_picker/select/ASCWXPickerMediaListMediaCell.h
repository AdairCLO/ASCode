//
//  ASCWXPickerMediaListMediaCell.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/11.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerMediaListMediaCell : UICollectionViewCell

@property (nonatomic, copy) NSString *mediaIdentifier;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIImageView *infoImageView;
@property (nonatomic, assign) BOOL disabled;

@end

NS_ASSUME_NONNULL_END
