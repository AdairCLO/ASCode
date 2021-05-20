//
//  ASCWXPickerContentContainerViewManager.m
//  ASCode
//
//  Created by Adair Wang on 2021/5/10.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerContentContainerViewManager.h"

@interface ASCWXPickerContentContainerViewManager ()

@property (nonatomic, strong) UIView *parentView;

@end

@implementation ASCWXPickerContentContainerViewManager

- (instancetype)initWithParentView:(UIView *)parentView
{
    self = [super init];
    if (self)
    {
        assert(parentView != nil);
        _parentView = parentView;
    }
    return self;
}

- (void)putViewToTop:(UIView *)view
{
    // move current view to top
    NSUInteger subviewCount = self.parentView.subviews.count;
    NSMutableArray<UIView *> *views = [[NSMutableArray alloc] init];
    [self.parentView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        if (v == view)
        {
            *stop = YES;
        }
        else
        {
            [v removeFromSuperview];
            [views addObject:v];
        }
    }];
    NSUInteger insertIndex = subviewCount - views.count - 1;
    [views enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.parentView insertSubview:v atIndex:insertIndex];
    }];
}

- (void)activeView:(ASCWXPickerContentContainerView *)view autoDeactive:(BOOL)autoDeactive
{
    [self.parentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ASCWXPickerContentContainerView *v = (ASCWXPickerContentContainerView *)obj;
        if ([v isKindOfClass:[ASCWXPickerContentContainerView class]])
        {
            [v deactive];
        }
    }];
    
    [view active:autoDeactive];
}

@end
