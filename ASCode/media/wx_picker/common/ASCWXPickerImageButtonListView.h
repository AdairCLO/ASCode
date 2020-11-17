//
//  ASCWXPickerImageButtonListView.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/28.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ASCWXPickerImageButtonListViewItemClickBlock)(NSUInteger btnIndex, BOOL isRadio, BOOL isSelected);

@interface ASCWXPickerImageButtonListViewItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, copy) void(^clickHandler)(NSUInteger btnIndex, BOOL isRadio, BOOL selected);

+ (instancetype)itemWithImage:(UIImage *)image clickHandler:(ASCWXPickerImageButtonListViewItemClickBlock)clickHandler;
+ (instancetype)itemWithImage:(UIImage *)image selectedImage:(nullable UIImage *)selectedImage clickHandler:(ASCWXPickerImageButtonListViewItemClickBlock)clickHandler;
- (instancetype)initWithImage:(UIImage *)image selectedImage:(nullable UIImage *)selectedImage clickHandler:(ASCWXPickerImageButtonListViewItemClickBlock)clickHandler;

@end

@interface ASCWXPickerImageButtonListView : UIView

@property (nonatomic, strong) NSArray<ASCWXPickerImageButtonListViewItem *> *items;

@end

NS_ASSUME_NONNULL_END
