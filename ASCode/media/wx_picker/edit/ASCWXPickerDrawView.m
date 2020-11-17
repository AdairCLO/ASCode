//
//  ASCWXPickerDrawView.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/3.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerDrawView.h"

@interface ASCWXPickerDrawViewStrokeData : NSObject

@property (nonatomic, strong) NSMutableArray<UIBezierPath *> *strockes;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;

- (instancetype)initWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;
- (void)removeLastStroke;

@end

@implementation ASCWXPickerDrawViewStrokeData

- (instancetype)initWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    self = [super init];
    if (self)
    {
        _strokeColor = color;
        _lineWidth = lineWidth;
        _strockes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)removeLastStroke
{
    [self.strockes removeLastObject];
}

@end

@interface ASCWXPickerDrawView ()

@property (nonatomic, strong) NSMutableArray<ASCWXPickerDrawViewStrokeData *> *strokeData;
@property (nonatomic, strong) UIBezierPath *drawingPath;

@end

@implementation ASCWXPickerDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _strokeColor = [UIColor blackColor];
        _lineWidth = 8;
        _strokeData = [[NSMutableArray alloc] init];
        [_strokeData addObject:[[ASCWXPickerDrawViewStrokeData alloc] initWithColor:_strokeColor lineWidth:_lineWidth]];
        
        self.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (_strokeColor == strokeColor)
    {
        return;
    }
    
    _strokeColor = strokeColor;
    if (self.strokeData.lastObject != nil && self.strokeData.lastObject.strockes.count == 0)
    {
        self.strokeData.lastObject.strokeColor = strokeColor;
    }
    else
    {
        [self.strokeData addObject:[[ASCWXPickerDrawViewStrokeData alloc] initWithColor:_strokeColor lineWidth:_lineWidth]];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    if (_lineWidth == lineWidth)
    {
        return;
    }
    
    _lineWidth = lineWidth;
    if (self.strokeData.lastObject != nil && self.strokeData.lastObject.strockes.count == 0)
    {
        self.strokeData.lastObject.lineWidth = lineWidth;
    }
    else
    {
        [self.strokeData addObject:[[ASCWXPickerDrawViewStrokeData alloc] initWithColor:_strokeColor lineWidth:_lineWidth]];
    }
}

- (BOOL)hasStroke
{
    __block BOOL hasData = NO;
    [self.strokeData enumerateObjectsUsingBlock:^(ASCWXPickerDrawViewStrokeData * _Nonnull strokeData, NSUInteger idx, BOOL * _Nonnull stop) {
        if (strokeData.strockes.count > 0)
        {
            hasData = YES;
            *stop = YES;
        }
    }];
    return hasData;
}

- (void)removeLastStroke
{
    if (self.drawingPath != nil)
    {
        return;
    }
    
    if (self.strokeData.count == 0)
    {
        return;
    }
    
    __block NSUInteger toRemoveIndex = NSNotFound;
    __block BOOL needUpdateDisplay = NO;
    [self.strokeData enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ASCWXPickerDrawViewStrokeData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        if (data.strockes.count > 0)
        {
            [data removeLastStroke];
            if (data.strockes.count == 0 && self.strokeData.lastObject != data)
            {
                toRemoveIndex = idx;
            }
            
            needUpdateDisplay = YES;
            *stop = YES;
        }
    }];
    
    if (toRemoveIndex != NSNotFound)
    {
        [self.strokeData removeObjectAtIndex:toRemoveIndex];
    }
    
    if (needUpdateDisplay)
    {
        [self setNeedsDisplay];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.receiveParentTouches && self.superview != nil)
    {
        CGPoint p = [self.superview convertPoint:point fromView:self];
        return [self.superview pointInside:p withEvent:event];
    }
    else
    {
        return [super pointInside:point withEvent:event];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    [self.strokeData enumerateObjectsUsingBlock:^(ASCWXPickerDrawViewStrokeData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        if (data.strockes.count == 0)
        {
            return;
        }
        
        UIColor *strokeColor = data.strokeColor;
        CGFloat lineWidth = data.lineWidth;
        
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        
        CGContextBeginPath(context);
        [data.strockes enumerateObjectsUsingBlock:^(UIBezierPath * _Nonnull p, NSUInteger idx, BOOL * _Nonnull stop) {
            CGContextAddPath(context, p.CGPath);
        }];
        CGContextDrawPath(context, kCGPathStroke);
    }];
}

// TODO: [edit] optimize: coalescedTouchesForTouch, predictedTouchesForTouch......

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    UIGestureRecognizerState state = pan.state;
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint p = [pan locationInView:self];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:p];
            
            self.drawingPath = path;
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint p = [pan locationInView:self];
            
            UIBezierPath *path = self.drawingPath;
            if (!CGPointEqualToPoint(path.currentPoint, p))
            {
                ASCWXPickerDrawViewStrokeData *strokeData = self.strokeData.lastObject;
                if (path != strokeData.strockes.lastObject)
                {
                    [strokeData.strockes addObject:path];
                    
                    if (self.startStrokeHandler != nil)
                    {
                        self.startStrokeHandler(self);
                    }
                }
                
                [path addLineToPoint:p];
                
                [self setNeedsDisplay];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (self.strokeData.lastObject.strockes.lastObject == self.drawingPath)
            {
                if (self.endStrokeHandler != nil)
                {
                    self.endStrokeHandler(self);
                }
            }
            self.drawingPath = nil;
            
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
