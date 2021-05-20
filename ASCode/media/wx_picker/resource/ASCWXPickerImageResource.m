//
//  ASCWXPickerImageResource.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerImageResource.h"

@implementation ASCWXPickerImageResource

+ (UIImage *)defaultMediaImage
{
    return [self imageWithColor:[UIColor whiteColor]];
}

+ (UIImage *)playbackImage
{
    CGSize size = CGSizeMake(80, 80);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:(size.width / 2)];
    [bezierPath fill];
    
    [[UIColor whiteColor] setStroke];
    bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(40, 40) radius:39 startAngle:0 endAngle:(M_PI * 2) clockwise:YES];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
    
    [[UIColor whiteColor] setFill];
    bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineWidth = 2;
    [bezierPath moveToPoint:CGPointMake(30, 24)];
    [bezierPath addLineToPoint:CGPointMake(58, 40)];
    [bezierPath addLineToPoint:CGPointMake(30, 56)];
    [bezierPath addLineToPoint:CGPointMake(30, 24)];
    [bezierPath stroke];
    [bezierPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)videoImage
{
    CGSize size = CGSizeMake(20, 12);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setStroke];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1, 13, 10)];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    bezierPath = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(16, 6);
    [bezierPath moveToPoint:CGPointMake(center.x, center.y - 2)];
    [bezierPath addLineToPoint:CGPointMake(19, center.y - 4)];
    [bezierPath addLineToPoint:CGPointMake(19, center.y + 4)];
    [bezierPath addLineToPoint:CGPointMake(center.x, center.y + 2)];
    [bezierPath closePath];
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageImage
{
    CGSize size = CGSizeMake(20, 12);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setStroke];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1, 15, 10)];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(2, 8)];
    [bezierPath addLineToPoint:CGPointMake(6, 4)];
    [bezierPath addLineToPoint:CGPointMake(10, 8)];
    [bezierPath addLineToPoint:CGPointMake(14, 4)];
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)cameraSwitchImage
{
    CGSize size = CGSizeMake(24, 24);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setFill];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, 8)];
    [bezierPath addLineToPoint:CGPointMake(0, 24)];
    [bezierPath addLineToPoint:CGPointMake(24, 24)];
    [bezierPath addLineToPoint:CGPointMake(24, 8)];
    [bezierPath addLineToPoint:CGPointMake(19, 8)];
    [bezierPath addLineToPoint:CGPointMake(16, 4)];
    [bezierPath addLineToPoint:CGPointMake(8, 4)];
    [bezierPath addLineToPoint:CGPointMake(5, 8)];
    [bezierPath fill];
    
    bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    // ->
    [bezierPath moveToPoint:CGPointMake(6, 13)];
    [bezierPath addLineToPoint:CGPointMake(18, 13)];
    [bezierPath addLineToPoint:CGPointMake(15, 11)];
    [bezierPath moveToPoint:CGPointMake(18, 13)];
    [bezierPath addLineToPoint:CGPointMake(15, 15)];
    // <-
    [bezierPath moveToPoint:CGPointMake(18, 19)];
    [bezierPath addLineToPoint:CGPointMake(6, 19)];
    [bezierPath addLineToPoint:CGPointMake(9, 17)];
    [bezierPath moveToPoint:CGPointMake(6, 19)];
    [bezierPath addLineToPoint:CGPointMake(9, 21)];
    
    [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)cameraCancelImage
{
    CGSize size = CGSizeMake(24, 24);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setFill];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:(size.width / 2)];
    [bezierPath fill];
    
    bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    [bezierPath moveToPoint:CGPointMake(7, 10)];
    [bezierPath addLineToPoint:CGPointMake(7 + 5, 10 + 5)];
    [bezierPath addLineToPoint:CGPointMake(7 + 5 + 5, 10)];
    [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)backImage
{
    CGSize size = CGSizeMake(26, 26);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setFill];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:(size.width / 2)];
    [bezierPath fill];
    
    bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    bezierPath.lineCapStyle = kCGLineCapSquare;
    // <-
    CGPoint center = CGPointMake(7, 11);
    [bezierPath moveToPoint:center];
    [bezierPath addLineToPoint:CGPointMake(center.x + 3, center.y - 3)];
    [bezierPath moveToPoint:center];
    [bezierPath addLineToPoint:CGPointMake(center.x + 3, center.y + 3)];
    [bezierPath moveToPoint:CGPointMake(center.x + 1, center.y)];
    [bezierPath addLineToPoint:CGPointMake(center.x + 8, center.y)];
    
    [bezierPath moveToPoint:CGPointMake(center.x + 9, center.y)];
    [bezierPath addArcWithCenter:CGPointMake(center.x + 9, center.y + 3) radius:3 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(center.x + 7, center.y + 6)];
    
    [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageEditDrawImage
{
    return [self imageWithString:@"画" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)imageEditSelectedDrawImage
{
    return [self imageWithString:@"画" size:CGSizeMake(20, 20) color:[UIColor greenColor]];
}

+ (UIImage *)imageEditEmojiImage
{
    return [self imageWithString:@"图" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)imageEditTextImage
{
    return [self imageWithString:@"字" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)imageEditCropImage
{
    return [self imageWithString:@"裁" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)imageEditMosaicImage
{
    return [self imageWithString:@"马" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)imageEditSelectedMosaicImage
{
    return [self imageWithString:@"马" size:CGSizeMake(20, 20) color:[UIColor greenColor]];
}

+ (UIImage *)videoEditEmojiImage
{
    return [self imageEditEmojiImage];
}

+ (UIImage *)videoEditTextImage
{
    return [self imageEditTextImage];
}

+ (UIImage *)videoEditAudioImage
{
    return [self imageWithString:@"音" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)videoEditClipImage
{
    return [self imageWithString:@"剪" size:CGSizeMake(20, 20) color:[UIColor whiteColor]];
}

+ (UIImage *)undoImage
{
    CGSize size = CGSizeMake(22, 22);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setStroke];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    bezierPath.lineCapStyle = kCGLineCapSquare;
    // <-
    CGPoint center = CGPointMake(8, 8);
    [bezierPath moveToPoint:center];
    [bezierPath addLineToPoint:CGPointMake(center.x + 3, center.y - 3)];
    [bezierPath moveToPoint:center];
    [bezierPath addLineToPoint:CGPointMake(center.x + 3, center.y + 3)];
    [bezierPath moveToPoint:CGPointMake(center.x + 1, center.y)];
    [bezierPath addLineToPoint:CGPointMake(center.x + 6, center.y)];
    
    [bezierPath moveToPoint:CGPointMake(center.x + 6, center.y)];
    [bezierPath addArcWithCenter:CGPointMake(center.x + 6, center.y + 5) radius:5 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(4, center.y + 10)];
    
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)textFgColorMode
{
    CGSize size = CGSizeMake(22, 22);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setStroke];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    bezierPath.lineCapStyle = kCGLineCapRound;
    [bezierPath moveToPoint:CGPointMake(1, 1)];
    [bezierPath addLineToPoint:CGPointMake(21, 1)];
    [bezierPath addLineToPoint:CGPointMake(21, 21)];
    [bezierPath addLineToPoint:CGPointMake(1, 21)];
    [bezierPath addLineToPoint:CGPointMake(1, 1)];
    [bezierPath stroke];
    
    // T
    [bezierPath moveToPoint:CGPointMake(5, 5)];
    [bezierPath addLineToPoint:CGPointMake(17, 5)];
    [bezierPath moveToPoint:CGPointMake(11, 5)];
    [bezierPath addLineToPoint:CGPointMake(11, 17)];
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)textBgColorMode
{
    CGSize size = CGSizeMake(22, 22);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    bezierPath.lineCapStyle = kCGLineCapRound;
    [bezierPath moveToPoint:CGPointMake(1, 1)];
    [bezierPath addLineToPoint:CGPointMake(21, 1)];
    [bezierPath addLineToPoint:CGPointMake(21, 21)];
    [bezierPath addLineToPoint:CGPointMake(1, 21)];
    [bezierPath addLineToPoint:CGPointMake(1, 1)];
    [bezierPath stroke];
    [bezierPath fill];
    
    // T
    bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2;
    bezierPath.lineCapStyle = kCGLineCapRound;
    [bezierPath moveToPoint:CGPointMake(5, 5)];
    [bezierPath addLineToPoint:CGPointMake(17, 5)];
    [bezierPath moveToPoint:CGPointMake(11, 5)];
    [bezierPath addLineToPoint:CGPointMake(11, 17)];
    [bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - code should be removed when we have image

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

+ (UIImage *)imageWithString:(NSString *)str size:(CGSize)size color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [str drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:@{
        NSForegroundColorAttributeName: color,
        NSFontAttributeName: [UIFont systemFontOfSize:size.width - 2],
    }];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
