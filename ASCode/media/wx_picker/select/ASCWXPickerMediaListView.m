//
//  ASCWXPickerMediaListView.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/11.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerMediaListView.h"
#import "ASCWXPickerListMediaModel.h"
#import "ASCWXPickerMediaListMediaCell.h"
#import "ASCWXPickerImageResource.h"

static const CGFloat kMargin = 16;
static const CGFloat kItemMargin = 12;

@interface ASCWXPickerMediaListView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ASCWXPickerListMediaModel *mediaModel;
@property (nonatomic, strong) NSMutableSet<NSString *> *disabledSet;

@end

@implementation ASCWXPickerMediaListView

- (instancetype)initWithFrame:(CGRect)frame mediaIdentifiers:(NSArray<NSString *> *)mediaIdentifiers
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemSize = frame.size.height - kMargin - kMargin;
        flowLayout.itemSize = CGSizeMake(itemSize, itemSize);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = kItemMargin;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, kMargin, 0, kMargin);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[ASCWXPickerMediaListMediaCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
        
        _mediaModel = [[ASCWXPickerListMediaModel alloc] initWithMediaIdentifers:mediaIdentifiers];
        _disabledSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)setDisabled:(BOOL)disabled withMediaIdentifier:(NSString *)mediaIdentifier
{
    if (mediaIdentifier.length == 0)
    {
        return;
    }
    
    if (disabled)
    {
        [self.disabledSet addObject:mediaIdentifier];
    }
    else
    {
        [self.disabledSet removeObject:mediaIdentifier];
    }
    
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof ASCWXPickerMediaListMediaCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        assert([cell isKindOfClass:[ASCWXPickerMediaListMediaCell class]]);
        if ([cell.mediaIdentifier isEqualToString:mediaIdentifier])
        {
            cell.disabled = disabled;
            *stop = YES;
        }
    }];
}

- (NSUInteger)mediaCount
{
    return self.mediaModel.count;
}

- (void)setSelectedMediaIdentifier:(NSString *)selectedMediaIdentifier
{
    if ([_selectedMediaIdentifier isEqualToString:selectedMediaIdentifier])
    {
        return;
    }
    
    NSUInteger index = [self.mediaModel indexWithIdentifier:selectedMediaIdentifier];
    if (index != NSNotFound)
    {
        _selectedMediaIdentifier = [selectedMediaIdentifier copy];
    }
    else
    {
        if (_selectedMediaIdentifier == nil)
        {
            return;
        }
        _selectedMediaIdentifier = nil;
    }
    
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof ASCWXPickerMediaListMediaCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        assert([cell isKindOfClass:[ASCWXPickerMediaListMediaCell class]]);
        cell.selected = [cell.mediaIdentifier isEqualToString:self.selectedMediaIdentifier];
    }];
    
    if (index != NSNotFound)
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (void)addWithMediaIdentifier:(NSString *)mediaIdentifier
{
    NSUInteger index = [self.mediaModel indexWithIdentifier:mediaIdentifier];
    if (index != NSNotFound)
    {
        return;
    }
    
    [self.mediaModel addWithMediaIdentifier:mediaIdentifier];
    if (self.window)
    {
        NSUInteger insertIndex = self.mediaModel.count - 1;
        [self.collectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:insertIndex inSection:0] ]];
    }
    else
    {
        [self.collectionView reloadData];
    }
    
    self.selectedMediaIdentifier = mediaIdentifier;
}
- (void)removeWithMediaIdentifier:(NSString *)mediaIdentifier
{
    NSUInteger removeIndex = [self.mediaModel indexWithIdentifier:mediaIdentifier];
    if (removeIndex == NSNotFound)
    {
        return;
    }
    
    [self.mediaModel removeWithMediaIdentifier:mediaIdentifier];
    [self.collectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:removeIndex inSection:0] ]];
    
    self.selectedMediaIdentifier = nil;
    [self.disabledSet removeObject:mediaIdentifier];
}

- (void)setEditedImageData:(NSDictionary<NSString *, UIImage *> *)editedImageData
{
    self.mediaModel.editedImageData = editedImageData;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaModel.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCWXPickerMediaListMediaCell *cell = (ASCWXPickerMediaListMediaCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSString *cellIdentifier = [self.mediaModel identifierWithIndex:indexPath.row];
    cell.mediaIdentifier = cellIdentifier;
    cell.imageView.image = nil;
    [self.mediaModel requestImageWithIndex:indexPath.row size:CGSizeMake(cell.frame.size.width, 0) completed:^(UIImage * _Nonnull image, NSString * _Nonnull mediaIdentifier) {
        if ([mediaIdentifier isEqualToString:cellIdentifier])
        {
            cell.imageView.image = image;
        }
    }];
    cell.selected = [cellIdentifier isEqualToString:self.selectedMediaIdentifier];
    cell.disabled = [self.disabledSet containsObject:cellIdentifier];
    
    UIImage *infoImage = nil;
    BOOL isVideo = [self.mediaModel isVideoWithIndex:indexPath.row];
    if (isVideo)
    {
        infoImage = [ASCWXPickerImageResource videoImage];
    }
    BOOL isEdited = [self.mediaModel isEditedWithIndex:indexPath.row];
    if (isEdited)
    {
        infoImage = [ASCWXPickerImageResource imageImage];
    }
    cell.infoImageView.image = infoImage;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMediaIdentifier = [self.mediaModel identifierWithIndex:indexPath.row];
    
    if (self.didSelectItemHandler != nil)
    {
        NSString *selectedIdentifier = [self.mediaModel identifierWithIndex:indexPath.row];
        self.didSelectItemHandler(selectedIdentifier);
    }
}

@end
