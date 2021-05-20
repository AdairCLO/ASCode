//
//  ASCWXPickerTextEditPlugin.m
//  ASCode
//
//  Created by Adair Wang on 2021/4/28.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerTextEditPlugin.h"
#import "ASCWXPickerTextEditViewController.h"

@interface ASCWXPickerTextEditPlugin ()

@end

@implementation ASCWXPickerTextEditPlugin

#pragma mark - ASCWXPickerEditPluginProtocol

@synthesize contentDidAddHandler = _contentDidAddHandler;
@synthesize contentDidRemoveHandler = _contentDidRemoveHandler;
@synthesize contentDidUpdateHandler = _contentDidUpdateHandler;
@synthesize contentDisplaySize = _contentDisplaySize;
@synthesize editStateChangedHandler = _editStateChangedHandler;

- (CGFloat)showOperationViewInContainerView:(UIView *)containerView
{
    return 0;
}

- (void)hideOperationView
{
    
}

- (void)presentOperationPageWithContainerVC:(UIViewController *)containerVC withContentView:(nullable UIView *)contentView
{
    if (self.editStateChangedHandler != nil)
    {
        self.editStateChangedHandler(YES);
    }
    
    UILabel *labelView = nil;
    if ([contentView isKindOfClass:[UILabel class]])
    {
        labelView = (UILabel *)contentView;
    }
    ASCWXPickerTextEditViewController *vc = [[ASCWXPickerTextEditViewController alloc] initWithLabel:labelView];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [containerVC presentViewController:vc animated:YES completion:nil];
    vc.completeHandler = ^(ASCWXPickerTextEditViewController * _Nonnull textEditVC, BOOL isCancelled) {
        
        if (self.editStateChangedHandler != nil)
        {
            self.editStateChangedHandler(NO);
        }
        
        UILabel *label = textEditVC.label;
        
        if (contentView == nil)
        {
            if (label.text.length > 0)
            {
                if (self.contentDidAddHandler != nil)
                {
                    self.contentDidAddHandler(label);
                }
            }
        }
        else
        {
            if (label.text.length == 0)
            {
                if (self.contentDidRemoveHandler != nil)
                {
                    self.contentDidRemoveHandler(label);
                }
            }
            else
            {
                // for isCancelled==YES, also fire the "contentDidUpdateHandler", to do some actions
                if (self.contentDidUpdateHandler != nil)
                {
                    self.contentDidUpdateHandler(label);
                }
            }
        }
    };
}

@end
