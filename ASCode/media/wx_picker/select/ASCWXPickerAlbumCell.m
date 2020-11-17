//
//  ASCWXPickerAlbumCell.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/14.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerAlbumCell.h"
#import "ASCWXPickerColorResource.h"

@interface ASCWXPickerAlbumCell ()

@property (nonatomic, strong) UIView *separatorView;

@end

@implementation ASCWXPickerAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1.0];
        [self addSubview:_separatorView];
        
        self.backgroundColor = [ASCWXPickerColorResource backgroundColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 10,
                                      (self.contentView.frame.size.height - self.textLabel.frame.size.height) / 2,
                                      self.textLabel.frame.size.width,
                                      self.textLabel.frame.size.height);
    
    _separatorView.frame = CGRectMake(self.bounds.size.height, self.frame.size.height - 0.5, self.frame.size.width - self.bounds.size.height, 0.5);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.backgroundColor = [UIColor blackColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.backgroundColor = [ASCWXPickerColorResource backgroundColor];;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.backgroundColor = [ASCWXPickerColorResource backgroundColor];;
}
@end
