//
//  ASCWXPickerMediaListMediaCell.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/11.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerMediaListMediaCell.h"
#import "ASCWXPickerColorResource.h"

@interface ASCWXPickerMediaListMediaCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *disabledView;

@end

@implementation ASCWXPickerMediaListMediaCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _infoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, self.bounds.size.height - 12 - 8, 20, 12)];
        _infoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _infoImageView.clipsToBounds = YES;
        [self.contentView addSubview:_infoImageView];
        
        self.contentView.layer.borderColor = [ASCWXPickerColorResource themeColor].CGColor;
    }
    return self;
}

- (UIView *)disabledView
{
    if (_disabledView == nil)
    {
        _disabledView = [[UIView alloc] initWithFrame:self.bounds];
        _disabledView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.contentView addSubview:_disabledView];
    }
    return _disabledView;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.contentView.layer.borderWidth = 4;
    }
    else
    {
        self.contentView.layer.borderWidth = 0;
    }
}

- (void)setDisabled:(BOOL)disabled
{
    _disabled = disabled;
    self.disabledView.hidden = !disabled;
}

@end
