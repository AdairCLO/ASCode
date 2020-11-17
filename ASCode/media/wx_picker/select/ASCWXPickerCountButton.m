//
//  ASCWXPickerCountButton.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerCountButton.h"
#import "ASCWXPickerColorResource.h"

@implementation ASCWXPickerCountButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        self.layer.cornerRadius = 3;
        
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        self.mainText = @"完成";
        
        [self updateEnableState];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self updateEnableState];
}

- (void)setMainText:(NSString *)mainText
{
    _mainText = [mainText copy];
    
    [self updateTextState];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    [self updateTextState];
}

- (void)updateTextState
{
    NSString *text = nil;
    if (self.count > 0)
    {
        text = [NSString stringWithFormat:@"%@ (%zd)", self.mainText, self.count];
    }
    else
    {
        text = self.mainText;
    }
    
    [self setTitle:text forState:UIControlStateNormal];
    [self sizeToFit];
}

- (void)updateEnableState
{
    if (self.enabled)
    {
        self.backgroundColor = [ASCWXPickerColorResource themeColor];
    }
    else
    {
        self.backgroundColor = [UIColor darkGrayColor];
    }
}

@end
