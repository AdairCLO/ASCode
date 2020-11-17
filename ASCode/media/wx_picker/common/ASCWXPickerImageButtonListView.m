//
//  ASCWXPickerImageButtonListView.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/28.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerImageButtonListView.h"

static const CGFloat kButtonSize = 40;
static const CGFloat kMargin = 8;

@implementation ASCWXPickerImageButtonListViewItem

+ (instancetype)itemWithImage:(UIImage *)image clickHandler:(ASCWXPickerImageButtonListViewItemClickBlock)clickHandler
{
    ASCWXPickerImageButtonListViewItem *item = [[ASCWXPickerImageButtonListViewItem alloc] initWithImage:image selectedImage:nil clickHandler:clickHandler];
    return item;
}

+ (instancetype)itemWithImage:(UIImage *)image selectedImage:(nullable UIImage *)selectedImage clickHandler:(ASCWXPickerImageButtonListViewItemClickBlock)clickHandler
{
    ASCWXPickerImageButtonListViewItem *item = [[ASCWXPickerImageButtonListViewItem alloc] initWithImage:image selectedImage:selectedImage clickHandler:clickHandler];
    return item;
}

- (instancetype)initWithImage:(UIImage *)image selectedImage:(nullable UIImage *)selectedImage clickHandler:(ASCWXPickerImageButtonListViewItemClickBlock)clickHandler
{
    self = [super init];
    if (self)
    {
        _image = image;
        _selectedImage = selectedImage;
        _clickHandler = [clickHandler copy];
    }
    return self;
}

@end

@interface ASCWXPickerImageButtonListView ()

@end

@implementation ASCWXPickerImageButtonListView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat y = (self.frame.size.height - kButtonSize) / 2;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        v.frame = CGRectMake(idx * (kButtonSize + kMargin), y, kButtonSize, kButtonSize);
    }];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetMaxX(self.subviews.lastObject.frame), self.frame.size.height);
}

- (void)setItems:(NSArray<ASCWXPickerImageButtonListViewItem *> *)items
{
    _items = items;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        [v removeFromSuperview];
    }];
    
    [items enumerateObjectsUsingBlock:^(ASCWXPickerImageButtonListViewItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *v = [self viewFromItem:item];
        v.tag = idx;
        [self addSubview:v];
    }];
    
    [self setNeedsLayout];
}

- (UIView *)viewFromItem:(ASCWXPickerImageButtonListViewItem *)item
{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:item.image forState:UIControlStateNormal];
    [button setImage:item.selectedImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)onButtonClicked:(UIButton *)btn
{
    ASCWXPickerImageButtonListViewItem *item = [self.items objectAtIndex:btn.tag];
    BOOL isRadioButton = (item.selectedImage != nil);
    if (isRadioButton)
    {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull b, NSUInteger idx, BOOL * _Nonnull stop) {
            if (b != btn)
            {
                b.selected = NO;
            }
        }];
        
        btn.selected = !btn.selected;
    }
    
    if (item.clickHandler != nil)
    {
        item.clickHandler(btn.tag, isRadioButton, btn.selected);
    }
}

@end
