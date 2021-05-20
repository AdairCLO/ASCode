//
//  ASCWXPickerDrawEditPlugin.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/5.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerDrawEditPlugin.h"
#import "ASCWXPickerDrawOperationView.h"
#import "ASCWXPickerDrawContentView.h"

@interface ASCWXPickerDrawEditPlugin ()

@property (nonatomic, strong) ASCWXPickerDrawOperationView *operationView;
@property (nonatomic, strong) ASCWXPickerDrawContentView *contentView;

@end

@implementation ASCWXPickerDrawEditPlugin

- (UIView *)operationView
{
    if (_operationView == nil)
    {
        _operationView = [[ASCWXPickerDrawOperationView alloc] init];
        __weak typeof(self) weakSelf = self;
        _operationView.colorChangedHandler = ^(ASCWXPickerDrawOperationView * _Nonnull view) {
            weakSelf.contentView.strokeColor = view.currentColor;
        };
        _operationView.undoHandler = ^(ASCWXPickerDrawOperationView * _Nonnull view) {
            [weakSelf.contentView removeLastStroke];
            [view setEnableUndo:[weakSelf.contentView hasStroke]];
        };
    }
    return _operationView;
}

- (ASCWXPickerDrawContentView *)contentView
{
    if (_contentView == nil)
    {
        _contentView = [[ASCWXPickerDrawContentView alloc] initWithFrame:CGRectMake(0, 0, _contentDisplaySize.width, _contentDisplaySize.height)];
        _contentView.receiveParentTouches = YES;
        _contentView.strokeColor = [self.operationView currentColor];
        _contentView.lineWidth = 6;
        __weak typeof(self) weakSelf = self;
        _contentView.startStrokeHandler = ^(ASCWXPickerDrawView * _Nonnull view) {
            if (weakSelf.editStateChangedHandler != nil)
            {
                weakSelf.editStateChangedHandler(YES);
            }
        };
        _contentView.endStrokeHandler = ^(ASCWXPickerDrawView * _Nonnull view) {
            [weakSelf.operationView setEnableUndo:YES];
            
            if (weakSelf.editStateChangedHandler != nil)
            {
                weakSelf.editStateChangedHandler(NO);
            }
        };
        
        if (self.contentDidAddHandler != nil)
        {
            self.contentDidAddHandler(_contentView);
        }
    }
    return _contentView;
}

#pragma mark - ASCWXPickerEditPluginProtocol

@synthesize contentDidAddHandler = _contentDidAddHandler;
@synthesize contentDidRemoveHandler = _contentDidRemoveHandler;
@synthesize contentDidUpdateHandler = _contentDidUpdateHandler;
@synthesize contentDisplaySize = _contentDisplaySize;
@synthesize editStateChangedHandler = _editStateChangedHandler;

- (CGFloat)showOperationViewInContainerView:(UIView *)containerView
{
    self.contentView.userInteractionEnabled = YES;
    
    self.operationView.frame = CGRectMake(0, 0, containerView.frame.size.width, 50);
    [containerView addSubview:self.operationView];
    
    return self.operationView.frame.size.height;
}

- (void)hideOperationView
{
    _contentView.userInteractionEnabled = NO;
    
    [_operationView removeFromSuperview];
}

- (void)presentOperationPageWithContainerVC:(UIViewController *)containerVC withContentView:(nullable UIView *)contentView;
{
    
}

@end
