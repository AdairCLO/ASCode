//
//  ASCWXPickerOccludeView.h
//  ASCode
//
//  Created by Adair Wang on 2021/5/15.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerOccludeView : UIView

@property (nonatomic, strong) UIColor *occludeColor;
@property (nonatomic, assign) CGFloat topOccludeHeight;
@property (nonatomic, assign) CGFloat bottomOccludeHeight;

@end

NS_ASSUME_NONNULL_END
