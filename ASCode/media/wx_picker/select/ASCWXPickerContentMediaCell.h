//
//  ASCWXPickerContentMediaCell.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerContentMediaCell;

@protocol ASCWXPickerContentMediaCellDelegate <NSObject>

@optional

- (void)pickerContentMediaCell:(ASCWXPickerContentMediaCell *)cell didSelectChanged:(BOOL)selected;

@end

@interface ASCWXPickerContentMediaCell : UICollectionViewCell

@property (nonatomic, weak) id<ASCWXPickerContentMediaCellDelegate> delegate;
@property (nonatomic, copy) NSString *mediaIdentifier;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIImageView *infoImageView;
@property (nonatomic, strong, readonly) UILabel *infoLabel;
@property (nonatomic, assign) NSUInteger selectedCountNumber;
@property (nonatomic, assign) BOOL disabled;

- (void)setSelectedCountNumber:(NSUInteger)selectedCountNumber animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
