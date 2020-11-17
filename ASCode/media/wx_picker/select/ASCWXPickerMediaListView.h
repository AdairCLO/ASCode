//
//  ASCWXPickerMediaListView.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/11.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerMediaListView : UIView

@property (nonatomic, copy, nullable) NSString *selectedMediaIdentifier;
@property (nonatomic, copy) void(^didSelectItemHandler)(NSString *itemIdentifier);

- (instancetype)initWithFrame:(CGRect)frame mediaIdentifiers:(NSArray<NSString *> *)mediaIdentifiers;

- (void)setDisabled:(BOOL)disabled withMediaIdentifier:(NSString *)mediaIdentifier;
- (NSUInteger)mediaCount;
- (void)addWithMediaIdentifier:(NSString *)mediaIdentifier;
- (void)removeWithMediaIdentifier:(NSString *)mediaIdentifier;
- (void)setEditedImageData:(NSDictionary<NSString *, UIImage *> *)editedImageData;

@end

NS_ASSUME_NONNULL_END
