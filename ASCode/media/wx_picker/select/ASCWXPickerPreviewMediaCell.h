//
//  ASCWXPickerPreviewMediaCell.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCWXPickerImageVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerPreviewMediaCell : UICollectionViewCell

@property (nonatomic, copy) NSString *mediaIdentifier;
@property (nonatomic, strong, readonly) ASCWXPickerImageVideoView *imageVideoView;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end

NS_ASSUME_NONNULL_END
