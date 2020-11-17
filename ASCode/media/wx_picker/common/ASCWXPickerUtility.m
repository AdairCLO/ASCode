//
//  ASCWXPickerUtility.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/20.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerUtility.h"

@implementation ASCWXPickerUtility

+ (UIImage *)imageWithColor:(UIColor *)color
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
