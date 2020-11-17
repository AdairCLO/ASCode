//
//  ASCWXPickerPreviewViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerPreviewViewController.h"
#import "ASCWXPickerTopBarView.h"
#import "ASCWXPickerBottomBarView.h"
#import "ASCWXPickerMediaModel.h"
#import "ASCWXPickerSelectedMediaData.h"
#import "ASCWXPickerCheckCountSwitch.h"
#import "ASCWXPickerCountButton.h"
#import "ASCWXPickerImageEditViewController.h"
#import "ASCWXPickerImageResource.h"
#import "ASCWXPickerLoadingViewController.h"
#import "ASCWXPickerPreviewMediaCell.h"
#import "ASCWXPickerMediaListView.h"

// TODO: [select] preview: scale image, gif

static const CGFloat kCollectionViewItemMargin = 10;

@interface ASCWXPickerPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ASCWXPickerImageEditViewControllerDelegate, ASCWXPickerImageVideoViewDelegate>

@property (nonatomic, strong) ASCWXPickerTopBarView *topBarView;
@property (nonatomic, strong) ASCWXPickerBottomBarView *bottomBarView;
@property (nonatomic, strong) id<ASCWXPickerMediaModelProviding> mediaModel;
@property (nonatomic, strong) UICollectionView *mediaCollectionView;
@property (nonatomic, strong) ASCWXPickerSelectedMediaData *selectedMediaData;
@property (nonatomic, strong) ASCWXPickerCheckCountSwitch *countSwitch;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) ASCWXPickerCountButton *doneButton;
@property (nonatomic, assign) BOOL isInsertMode;
@property (nonatomic, assign) NSUInteger firstDisplayIndex;
@property (nonatomic, strong) ASCWXPickerMediaListView *mediaListView;

@end

@implementation ASCWXPickerPreviewViewController

@synthesize pickerStepPageDelegate = _pickerStepPageDelegate;

- (instancetype)initWithMediaModel:(id<ASCWXPickerMediaModelProviding>)mediaModel selectedMediaData:(ASCWXPickerSelectedMediaData *)selectedMediaData isInsertMode:(BOOL)isInsertMode
{
    return [self initWithMediaModel:mediaModel selectedMediaData:selectedMediaData isInsertMode:isInsertMode firstDisplayIndex:0];
}

- (instancetype)initWithMediaModel:(id<ASCWXPickerMediaModelProviding>)mediaModel selectedMediaData:(ASCWXPickerSelectedMediaData *)selectedMediaData isInsertMode:(BOOL)isInsertMode firstDisplayIndex:(NSUInteger)firstDisplayIndex
{
    self = [super init];
    if (self)
    {
        _mediaModel = mediaModel;
        assert(_mediaModel.count > 0);
        _selectedMediaData = selectedMediaData;
        _isInsertMode = isInsertMode;
        _firstDisplayIndex = firstDisplayIndex;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // top bar
    _topBarView = [[ASCWXPickerTopBarView alloc] init];
    [self.view addSubview:_topBarView];
    // top bar - left
    UIButton *topBarViewLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [topBarViewLeftButton setTitle:@"取消" forState:UIControlStateNormal];
    topBarViewLeftButton.titleLabel.font = [UIFont systemFontOfSize:17];
    topBarViewLeftButton.tintColor = [UIColor whiteColor];
    [topBarViewLeftButton sizeToFit];
    [topBarViewLeftButton addTarget:self action:@selector(onBackClicked) forControlEvents:UIControlEventTouchUpInside];
    _topBarView.leftView = topBarViewLeftButton;
    // top bar - right
    CGFloat countSwitchSize = 40;
    ASCWXPickerCheckCountSwitch *topBarViewRightButton = [[ASCWXPickerCheckCountSwitch alloc] initWithFrame:CGRectMake(0, 0, countSwitchSize, countSwitchSize)];
    [topBarViewRightButton addTarget:self action:@selector(onCountSwitchClicked) forControlEvents:UIControlEventTouchUpInside];
    _topBarView.rightView = topBarViewRightButton;
    _countSwitch = topBarViewRightButton;
    
    // bottom bar
    _bottomBarView = [[ASCWXPickerBottomBarView alloc] init];
    [self.view addSubview:_bottomBarView];
    // bottom bar - left
    UIButton *bottomBarViewLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [bottomBarViewLeftButton setTitle:@"编辑" forState:UIControlStateNormal];
    bottomBarViewLeftButton.titleLabel.font = [UIFont systemFontOfSize:17];
    bottomBarViewLeftButton.tintColor = [UIColor whiteColor];
    [bottomBarViewLeftButton sizeToFit];
    [bottomBarViewLeftButton addTarget:self action:@selector(onEditClicked) forControlEvents:UIControlEventTouchUpInside];
    bottomBarViewLeftButton.hidden = NO; // only image can be edit
    _bottomBarView.leftView = bottomBarViewLeftButton;
    _editButton = bottomBarViewLeftButton;
    // bottom bar - right
    ASCWXPickerCountButton *bottomBarViewRightButton = [[ASCWXPickerCountButton alloc] init];
    [bottomBarViewRightButton addTarget:self action:@selector(onDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    bottomBarViewRightButton.enabled = self.selectedMediaData.count > 0;
    bottomBarViewRightButton.count = self.selectedMediaData.count;
    _bottomBarView.rightView = bottomBarViewRightButton;
    _doneButton = bottomBarViewRightButton;
    // bottom bar - top
    _mediaListView = [[ASCWXPickerMediaListView alloc] initWithFrame:CGRectMake(0, 0, _bottomBarView.frame.size.width, 96) mediaIdentifiers:self.selectedMediaData.selectedMediaIdentifiers];
    _mediaListView.selectedMediaIdentifier = [self.mediaModel identifierWithIndex:self.firstDisplayIndex];
    __weak typeof(self) weakSelf = self;
    _mediaListView.didSelectItemHandler = ^(NSString * _Nonnull itemIdentifier) {
        ASCWXPickerPreviewMediaCell *currentCell = [weakSelf currentCell];
        if (![currentCell.mediaIdentifier isEqualToString:itemIdentifier])
        {
            NSUInteger targetIndex = [weakSelf.mediaModel indexWithIdentifier:itemIdentifier];
            if (targetIndex != NSNotFound)
            {
                [weakSelf.mediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            }
        }
    };
    if (_mediaListView.mediaCount > 0)
    {
        _bottomBarView.topView = _mediaListView;
    }
    [_mediaListView setEditedImageData:self.mediaModel.editedImageData];
    
    // collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width + kCollectionViewItemMargin, self.view.frame.size.height);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _mediaCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, flowLayout.itemSize.width, flowLayout.itemSize.height) collectionViewLayout:flowLayout];
    [_mediaCollectionView registerClass:[ASCWXPickerPreviewMediaCell class] forCellWithReuseIdentifier:@"cell"];
    _mediaCollectionView.dataSource = self;
    _mediaCollectionView.delegate = self;
    _mediaCollectionView.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        _mediaCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _mediaCollectionView.showsVerticalScrollIndicator = NO;
    _mediaCollectionView.showsHorizontalScrollIndicator = NO;
    _mediaCollectionView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:_mediaCollectionView atIndex:0];
    if (self.firstDisplayIndex > 0 && self.firstDisplayIndex < self.mediaModel.count)
    {
        [_mediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.firstDisplayIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self updateControlStateForCurrentMedia];
}

- (void)updateControlStateForCurrentMedia
{
    NSUInteger currentIndex = [self currentMediaIndex];
    NSString *currentIdentifier = [self.mediaModel identifierWithIndex:currentIndex];
    
    NSInteger selectedIndex = [self.selectedMediaData indexOfMediaWithIdentifier:currentIdentifier];
    BOOL selected = (index >= 0);
    
    if (selected)
    {
        [self.countSwitch setCount:(selectedIndex + 1) animated:NO];
    }
    else
    {
        [self.countSwitch setCount:0 animated:NO];
    }
    self.countSwitch.hidden = !self.selectedMediaData.canSelectMore;
    
    BOOL isVideo = [self.mediaModel isVideoWithIndex:currentIndex];
    self.editButton.hidden = isVideo;
    
    self.mediaListView.selectedMediaIdentifier = currentIdentifier;
    
    // stop video
    if (isVideo)
    {
        ASCWXPickerPreviewMediaCell *cell = (ASCWXPickerPreviewMediaCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
        [cell.imageVideoView stop];
    }
}

- (NSUInteger)currentMediaIndex
{
    NSUInteger index = 0;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.mediaCollectionView.collectionViewLayout;
    assert([flowLayout isKindOfClass:[UICollectionViewFlowLayout class]]);
    CGFloat itemWidth = flowLayout.itemSize.width;
    CGFloat indexFloat = self.mediaCollectionView.contentOffset.x / itemWidth;
    if (indexFloat >= 0)
    {
        index = floor(indexFloat);
    
        if ((indexFloat - index) >= 0.5)
        {
            index += 1;
        }
        
        index = MIN(index, self.mediaModel.count - 1);
    }
    return index;
}

- (ASCWXPickerPreviewMediaCell *)currentCell
{
    ASCWXPickerPreviewMediaCell *cell = (ASCWXPickerPreviewMediaCell *)self.mediaCollectionView.visibleCells.firstObject;
    assert([cell isKindOfClass:[ASCWXPickerPreviewMediaCell class]]);
    return cell;
}

- (NSDictionary<NSString *, UIImage *> *)editedImageData
{
    return self.mediaModel.editedImageData;
}

#pragma mark - button

- (void)onBackClicked
{
    if (self.delegate != nil)
    {
        [self.delegate previewViewControllerWillBack:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onCountSwitchClicked
{
    NSUInteger currentIndex = [self currentMediaIndex];
    NSString *currentIdentifier = [self.mediaModel identifierWithIndex:currentIndex];
    
    NSUInteger count = 0;
    BOOL toDeselect = self.countSwitch.isSelected;
    if (toDeselect)
    {
        [self.selectedMediaData deselectMediaWithIdentifier:currentIdentifier];
    }
    else if (self.selectedMediaData.canSelectMore)
    {
        NSUInteger insertIndex = self.selectedMediaData.count;
        if (self.isInsertMode)
        {
            insertIndex = [self currentMediaIndex];
        }
        [self.selectedMediaData selectMediaWithIdentifier:currentIdentifier atIndex:insertIndex];
        
        count = (insertIndex + 1);
    }
    [self.countSwitch setCount:count animated:YES];
    
    self.doneButton.enabled = self.selectedMediaData.count > 0;
    self.doneButton.count = self.selectedMediaData.count;
    
    // mediaListView
    if (self.isInsertMode)
    {
        // do not add/remove items of mediaListView
        [self.mediaListView setDisabled:toDeselect withMediaIdentifier:currentIdentifier];
    }
    else
    {
        // add/remove items of mediaListView
        if (toDeselect)
        {
            [self.mediaListView removeWithMediaIdentifier:currentIdentifier];
        }
        else
        {
            [self.mediaListView addWithMediaIdentifier:currentIdentifier];
        }
    }
    if (self.mediaListView.mediaCount > 0)
    {
        self.bottomBarView.topView = self.mediaListView;
    }
    else
    {
        self.bottomBarView.topView = nil;
    }
}

- (void)onEditClicked
{
    UIImage *currentImage = [self currentCell].imageVideoView.image;
    if (currentImage.size.width == 0 || currentImage.size.height == 0)
    {
        return;
    }
    ASCWXPickerImageEditViewController *imageEditVC = [[ASCWXPickerImageEditViewController alloc] initWithImage:currentImage];
    imageEditVC.delegate = self;
    [self.navigationController pushViewController:imageEditVC animated:NO];
}

- (void)onDoneClicked
{
    // TODO: if need save the capture image/video?? or config to decide to save or not
    
    ASCWXPickerLoadingViewController *loadingVC = [[ASCWXPickerLoadingViewController alloc] init];
    [self presentViewController:loadingVC animated:NO completion:nil];
    
    [self.selectedMediaData requestAllSelectedMediaWithCompleted:^(NSArray<ASCWXPickerResult *> * _Nonnull results) {
        [loadingVC dismissViewControllerAnimated:NO completion:^{
            [self.pickerStepPageDelegate pickerStepPage:self didFinishPicking:results];
        }];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaModel.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCWXPickerPreviewMediaCell *cell = (ASCWXPickerPreviewMediaCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, kCollectionViewItemMargin);
    
    cell.imageVideoView.delegate = self;
    
    BOOL isVideo = [self.mediaModel isVideoWithIndex:indexPath.row];
    NSString *cellIdentifier = [self.mediaModel identifierWithIndex:indexPath.row];
    cell.mediaIdentifier = cellIdentifier;
    cell.imageVideoView.image = nil;
    cell.imageVideoView.videoAsset = nil;
    
    if (isVideo)
    {
        [self.mediaModel requestVideoWithIndex:indexPath.row completed:^(AVAsset * _Nonnull videoAsset, NSString * _Nonnull mediaIdentifier) {
            if ([mediaIdentifier isEqualToString:cellIdentifier])
            {
                cell.imageVideoView.videoAsset = videoAsset;
            }
        }];
    }
    else
    {
        CGFloat imageSize = self.view.bounds.size.width;
        [self.mediaModel requestImageWithIndex:indexPath.row size:CGSizeMake(imageSize, imageSize) completed:^(UIImage * _Nonnull image, NSString * _Nonnull mediaIdentifier) {
            if ([mediaIdentifier isEqualToString:cellIdentifier])
            {
                cell.imageVideoView.image = image;
            }
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateControlStateForCurrentMedia];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self updateControlStateForCurrentMedia];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateControlStateForCurrentMedia];
}

#pragma mark - ASCWXPickerImageEditViewControllerDelegate

- (void)imageEidtVC:(ASCWXPickerImageEditViewController *)imageEditVC didCompleteWithEditedImage:(UIImage *)editedImage;
{
    if (editedImage != nil)
    {
        ASCWXPickerPreviewMediaCell *cell = [self currentCell];
        if (cell.mediaIdentifier.length > 0)
        {
            NSDictionary<NSString *, UIImage *> *editedImageData = nil;
            if (self.mediaModel.editedImageData == nil)
            {
                editedImageData = @{ cell.mediaIdentifier: editedImage };
            }
            else
            {
                NSMutableDictionary<NSString *, UIImage *> *goodEditedImageData = [self.mediaModel.editedImageData mutableCopy];
                [goodEditedImageData setValue:editedImage forKey:cell.mediaIdentifier];
                
                editedImageData = goodEditedImageData;
            }
            self.mediaModel.editedImageData = editedImageData;
            self.selectedMediaData.editedImageData = editedImageData;
            
            NSIndexPath *indexPath = [self.mediaCollectionView indexPathForCell:cell];
            [self.mediaCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            
            [self.mediaListView setEditedImageData:editedImageData];
        }
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)imageEditVCWillClose:(ASCWXPickerImageEditViewController *)imageEditVC
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - ASCWXPickerImageVideoViewDelegate

- (void)imageVideoViewVideoPlaybackButtonDidClick:(ASCWXPickerImageVideoView *)imageVideoView
{
    if (imageVideoView.isVideoPlaying)
    {
        [self hideBarViews];
    }
    else
    {
        [self showBarViews];
    }
}

- (void)imageVideoViewVideoDidPlayToEnd:(ASCWXPickerImageVideoView *)imageVideoView
{
    [self showBarViews];
}

#pragma mark - gesture

- (void)onTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.topBarView.alpha == 1)
    {
        CGPoint p = [gestureRecognizer locationInView:self.view];
        if (CGRectContainsPoint(self.topBarView.frame, p)
            || CGRectContainsPoint(self.bottomBarView.frame, p))
        {
            return;
        }
    }
    
    [self toggleShowHideBarViews];
}

- (void)showBarViews
{
    [self.topBarView showBarView:YES];
    [self.bottomBarView showBarView:YES];
}

- (void)hideBarViews
{
    [self.topBarView hideBarView:YES];
    [self.bottomBarView hideBarView:YES];
}

- (void)toggleShowHideBarViews
{
    [self.topBarView toggleShowHideBarView:YES];
    [self.bottomBarView toggleShowHideBarView:YES];
}

@end
