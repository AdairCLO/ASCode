//
//  UIButton+ASCButton.m
//  GymTimer
//
//  Created by Adair Wang on 2020/5/29.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "UIButton+ASCButton.h"

@implementation UIButton (ASCButton)

- (void)asc_setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    UIImage *image = [[self class] asc_imageWithColor:color];
    [self setBackgroundImage:image forState:state];
}

+ (UIImage *)asc_imageWithColor:(UIColor *)color
{
    if (color == nil)
    {
        return nil;
    }
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
