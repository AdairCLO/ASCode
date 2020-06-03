//
//  UIButton+ASCButton.h
//  GymTimer
//
//  Created by Adair Wang on 2020/5/29.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ASCButton)

- (void)asc_setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
