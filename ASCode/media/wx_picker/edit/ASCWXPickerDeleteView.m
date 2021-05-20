//
//  ASCWXPickerDeleteView.m
//  ASCode
//
//  Created by Adair Wang on 2021/5/15.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerDeleteView.h"

@interface ASCWXPickerDeleteView ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ASCWXPickerDeleteView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 20;
        
        // TODO: delete view UI
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textColor = [UIColor whiteColor];
        [self addSubview:_textLabel];
        
        [self updateDeleteMode:NO];
    }
    return self;
}

- (void)setDeleteMode:(BOOL)deleteMode
{
    if (deleteMode == _deleteMode)
    {
        return;
    }
    _deleteMode = deleteMode;
    
    [self updateDeleteMode:deleteMode];
}

- (void)updateDeleteMode:(BOOL)deleteMode
{
    if (deleteMode)
    {
        self.textLabel.text = @"松手即可删除";
        [self.textLabel sizeToFit];
        self.textLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        
        self.backgroundColor = [UIColor redColor];
    }
    else
    {
        self.textLabel.text = @"拖动到此处删除";
        [self.textLabel sizeToFit];
        self.textLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        
        self.backgroundColor = [UIColor darkGrayColor];
    }
}

@end
