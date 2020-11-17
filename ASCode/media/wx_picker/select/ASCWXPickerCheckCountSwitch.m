//
//  ASCWXPickerCheckCountSwitch.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerCheckCountSwitch.h"

@implementation ASCWXPickerCheckCountSwitch

- (CALayer *)buildEmptyLayerWithFrame:(CGRect)frame
{
    CAShapeLayer *emptyLayer = [CAShapeLayer layer];
    emptyLayer.frame = frame;
    emptyLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    emptyLayer.cornerRadius = frame.size.width / 2;
    emptyLayer.borderColor = [UIColor whiteColor].CGColor;
    emptyLayer.borderWidth = 1;
    
    CGPoint center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(center.x - 5, center.y)];
    [path addLineToPoint:CGPointMake(center.x - 2, center.y + 5)];
    [path addLineToPoint:CGPointMake(center.x + 5, center.y - 5)];
    emptyLayer.path = path.CGPath;
    emptyLayer.strokeColor = [UIColor whiteColor].CGColor;
    emptyLayer.lineWidth = 1;
    
    return emptyLayer;
}
@end
