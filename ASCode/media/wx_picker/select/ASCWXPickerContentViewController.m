//
//  ASCWXPickerContentViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerContentViewController.h"
#import "ASCWXPickerTopBarView.h"
#import "ASCWXPickerBottomBarView.h"
#import "ASCWXPickerSelectButton.h"
#import "ASCWXPickerAlbumListView.h"
#import "ASCWXPickerMediaModel.h"
#import "ASCWXPickerContentMediaCell.h"
#import "ASCWXPickerSelectedMediaData.h"
#import "ASCWXPickerCountButton.h"
#import "ASCWXPickerResult.h"
#import "ASCWXPickerLoadingViewController.h"
#import "ASCWXPickerAlertViewController.h"
#import "ASCWXPickerColorResource.h"
#import "ASCWXPickerImageResource.h"
#import "ASCWXPickerPreviewViewController.h"
#import "ASCWXPickerListMediaModel.h"

@interface ASCWXPickerContentViewController () <ASCWXPickerAlbumListViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ASCWXPickerContentMediaCellDelegate, ASCWXPickerPreviewViewControllerDelegate>

@property (nonatomic, strong) ASCWXPickerTopBarView *topBarView;
@property (nonatomic, strong) ASCWXPickerBottomBarView *bottomBarView;
@property (nonatomic, strong) ASCWXPickerAlbumListView *albumListView;
@property (nonatomic, strong) ASCWXPickerSelectButton *selectButton;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) ASCWXPickerCountButton *doneButton;
@property (nonatomic, strong) ASCWXPickerMediaModel *mediaModel;
@property (nonatomic, strong) UICollectionView *mediaCollectionView;
@property (nonatomic, strong) ASCWXPickerSelectedMediaData *selectedMediaData;

@end

@implementation ASCWXPickerContentViewController

@synthesize pickerStepPageDelegate = _pickerStepPageDelegate;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _mediaModel = [[ASCWXPickerMediaModel alloc] init];
        _selectedMediaData = [[ASCWXPickerSelectedMediaData alloc] init];
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
    [topBarViewLeftButton addTarget:self action:@selector(onCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    _topBarView.leftView = topBarViewLeftButton;
    // top bar - center
    ASCWXPickerSelectButton *topBarViewCenterButton = [[ASCWXPickerSelectButton alloc] init];
    [topBarViewCenterButton setTitle:self.mediaModel.albumTitle];
    [topBarViewCenterButton sizeToFit];
    [topBarViewCenterButton addTarget:self action:@selector(onShowOrHideMediaAlbumListClicked:) forControlEvents:UIControlEventTouchUpInside];
    _topBarView.centerView = topBarViewCenterButton;
    _selectButton = topBarViewCenterButton;
    
    // bottom bar
    _bottomBarView = [[ASCWXPickerBottomBarView alloc] init];
    [self.view addSubview:_bottomBarView];
    // bottom bar - left
    UIButton *bottomBarViewLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [bottomBarViewLeftButton setTitle:@"预览" forState:UIControlStateNormal];
    bottomBarViewLeftButton.titleLabel.font = [UIFont systemFontOfSize:17];
    bottomBarViewLeftButton.tintColor = [UIColor whiteColor];
    [bottomBarViewLeftButton sizeToFit];
    [bottomBarViewLeftButton addTarget:self action:@selector(onPreviewClicked) forControlEvents:UIControlEventTouchUpInside];
    bottomBarViewLeftButton.enabled = self.selectedMediaData.count > 0;
    _bottomBarView.leftView = bottomBarViewLeftButton;
    _previewButton = bottomBarViewLeftButton;
    // bottom bar - right
    ASCWXPickerCountButton *bottomBarViewRightButton = [[ASCWXPickerCountButton alloc] init];
    [bottomBarViewRightButton addTarget:self action:@selector(onDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    bottomBarViewRightButton.enabled = self.selectedMediaData.count > 0;
    _bottomBarView.rightView = bottomBarViewRightButton;
    _doneButton = bottomBarViewRightButton;
    
    // TODO: [select] "origin image" button
    
    // collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    NSUInteger itemCount = 4;
    CGFloat itemMargin = 3;
    if (self.view.frame.size.width > 375)
    {
        itemMargin = 10;
    }
    CGFloat itemSize = floor((self.view.frame.size.width - itemMargin * (itemCount + 1)) / itemCount);
    flowLayout.itemSize = CGSizeMake(itemSize, itemSize);
    flowLayout.minimumInteritemSpacing = itemMargin;
    flowLayout.minimumLineSpacing = itemMargin;
    flowLayout.sectionInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    _mediaCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [_mediaCollectionView registerClass:[ASCWXPickerContentMediaCell class] forCellWithReuseIdentifier:@"cell"];
    _mediaCollectionView.dataSource = self;
    _mediaCollectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        _mediaCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _mediaCollectionView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(_topBarView.frame), 0, CGRectGetHeight(_bottomBarView.frame), 0);
    _mediaCollectionView.alwaysBounceVertical = YES;
    _mediaCollectionView.backgroundColor = [ASCWXPickerColorResource backgroundColor];
    // top inset: no need to add the height of the "status bar"...
    _mediaCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(_topBarView.contentHeight, 0, CGRectGetHeight(_bottomBarView.frame), 0);
    [self.view insertSubview:_mediaCollectionView belowSubview:_topBarView];
    [self scrollMediaCollectionViewToEnd];
}

- (ASCWXPickerAlbumListView *)albumListView
{
    if (_albumListView == nil)
    {
        _albumListView = [[ASCWXPickerAlbumListView alloc] initWithFrame:CGRectMake(0,
                                                                                    CGRectGetMaxY(self.topBarView.frame),
                                                                                    self.view.bounds.size.width,
                                                                                    self.view.bounds.size.height - CGRectGetMaxY(self.topBarView.frame))];
        _albumListView.delegate = self;
        [self.view addSubview:_albumListView];
    }
    return _albumListView;
}

- (void)scrollMediaCollectionViewToEnd
{
    if (self.mediaModel.count == 0)
    {
        return;
    }
    
    [self.mediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(self.mediaModel.count - 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.mediaCollectionView.collectionViewLayout;
    if ([flowLayout isKindOfClass:[UICollectionViewFlowLayout class]])
    {
        self.mediaCollectionView.contentOffset = CGPointMake(self.mediaCollectionView.contentOffset.x, self.mediaCollectionView.contentOffset.y + flowLayout.sectionInset.bottom);
    }
}

#pragma mark - ASCWXPickerAlbumListViewDelegate

- (void)pickerAlbumListView:(ASCWXPickerAlbumListView *)view didSelectAlbumWithIdentifier:(NSString *)identifier title:(NSString *)title
{
    self.mediaModel.albumIdentifier = identifier;
    [self.mediaCollectionView reloadData];
    [self scrollMediaCollectionViewToEnd];
    
    [self checkSelectButtonStatus];
    [self hideAlbumListView];
}

- (void)pickerAlbumListViewDidCancel:(ASCWXPickerAlbumListView *)view
{
    [self checkSelectButtonStatus];
    [self hideAlbumListView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaModel.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCWXPickerContentMediaCell *cell = (ASCWXPickerContentMediaCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    
    NSString *cellIdentifier = [self.mediaModel identifierWithIndex:indexPath.row];
    cell.mediaIdentifier = cellIdentifier;
    cell.imageView.image = nil;
    CGFloat imageSize = 120;
    [self.mediaModel requestImageWithIndex:indexPath.row size:CGSizeMake(imageSize, imageSize) completed:^(UIImage * _Nonnull image, NSString * _Nonnull mediaIdentifier) {
        if ([mediaIdentifier isEqualToString:cellIdentifier])
        {
            cell.imageView.image = image;
        }
    }];
    
    NSInteger selectedIndex = [self.selectedMediaData indexOfMediaWithIdentifier:cellIdentifier];
    cell.selectedCountNumber = selectedIndex + 1;
    cell.disabled = (selectedIndex == -1 && ![self.selectedMediaData canSelectMore]);
    
    UIImage *infoImage = nil;
    NSString *info = nil;
    BOOL isVideo = [self.mediaModel isVideoWithIndex:indexPath.row];
    if (isVideo)
    {
        infoImage = [ASCWXPickerImageResource videoImage];
        
        NSTimeInterval duration = [self.mediaModel durationWithIndex:indexPath.row];
        NSInteger minutes = (NSInteger)floor(duration / 60);
        NSInteger seconds = (NSInteger)((NSInteger)duration % 60);
        info = [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
    }
    BOOL isEdited = [self.mediaModel isEditedWithIndex:indexPath.row];
    if (isEdited)
    {
        infoImage = [ASCWXPickerImageResource imageImage];
    }
    cell.infoImageView.image = infoImage;
    cell.infoLabel.text = info;
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCWXPickerContentMediaCell *mediaCell = (ASCWXPickerContentMediaCell *)cell;
    assert([mediaCell isKindOfClass:[ASCWXPickerContentMediaCell class]]);
    NSString *cellIdentifier = mediaCell.mediaIdentifier;
    
    NSInteger selectedIndex = [self.selectedMediaData indexOfMediaWithIdentifier:cellIdentifier];
    mediaCell.selectedCountNumber = selectedIndex + 1;
    mediaCell.disabled = (selectedIndex == -1 && ![self.selectedMediaData canSelectMore]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCWXPickerPreviewViewController *previewVC = [[ASCWXPickerPreviewViewController alloc] initWithMediaModel:self.mediaModel selectedMediaData:self.selectedMediaData isInsertMode:NO firstDisplayIndex:indexPath.row];
    previewVC.delegate = self;
    [self.navigationController pushViewController:previewVC animated:YES];
}

#pragma mark - button

- (void)onCancelClicked
{
    [self.pickerStepPageDelegate pickerStepPage:self didFinishPicking:@[]];
}

- (void)onShowOrHideMediaAlbumListClicked:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        [self showAlbumListView];
    }
    else
    {
        [self hideAlbumListView];
    }
}

- (void)onPreviewClicked
{
    ASCWXPickerListMediaModel *listMediaModel = [[ASCWXPickerListMediaModel alloc] initWithMediaIdentifers:self.selectedMediaData.selectedMediaIdentifiers];
    listMediaModel.editedImageData = self.mediaModel.editedImageData;
    
    ASCWXPickerPreviewViewController *previewVC = [[ASCWXPickerPreviewViewController alloc] initWithMediaModel:listMediaModel selectedMediaData:self.selectedMediaData isInsertMode:YES];
    previewVC.delegate = self;
    [self.navigationController pushViewController:previewVC animated:YES];
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

#pragma mark - ASCWXPickerContentMediaCellDelegate

- (void)pickerContentMediaCell:(ASCWXPickerContentMediaCell *)cell didSelectChanged:(BOOL)selected
{
    if (selected)
    {
        [self.selectedMediaData selectMediaWithIdentifier:cell.mediaIdentifier];
        
        if ([self.selectedMediaData indexOfMediaWithIdentifier:cell.mediaIdentifier] == -1)
        {
            // TODO: [ui] show/hide transition
            NSString *alertTitle = [NSString stringWithFormat:@"你最多只能选择%zd张照片", self.selectedMediaData.maxSelection];
            ASCWXPickerAlertViewController *alertVC = [[ASCWXPickerAlertViewController alloc] initWithTitle:alertTitle];
            [self presentViewController:alertVC animated:NO completion:nil];
            return;
        }
    }
    else
    {
        [self.selectedMediaData deselectMediaWithIdentifier:cell.mediaIdentifier];
    }

    [self checkVisibleCellStatus:YES];
    [self checkButtonStatus];
}

#pragma mark - ASCWXPickerPreviewViewControllerDelegate

- (void)previewViewControllerWillBack:(ASCWXPickerPreviewViewController *)previewVC
{
    self.selectedMediaData = previewVC.selectedMediaData;
    self.mediaModel.editedImageData = previewVC.editedImageData;
    self.selectedMediaData.editedImageData = previewVC.editedImageData;
    
    [self checkVisibleCellStatus:NO];
    [self checkButtonStatus];
}

#pragma mark - private

- (void)showAlbumListView
{
    [self.albumListView showView];
}

- (void)hideAlbumListView
{
    [self.albumListView hideView];
}

- (void)checkSelectButtonStatus
{
    self.selectButton.selected = NO;
    
    [self.selectButton setTitle:self.mediaModel.albumTitle];
    [self.selectButton updateSize];
}

- (void)checkVisibleCellStatus:(BOOL)animated
{
    [self.mediaCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ASCWXPickerContentMediaCell *mediaCell = (ASCWXPickerContentMediaCell *)obj;
        NSIndexPath *indexPath = [self.mediaCollectionView indexPathForCell:mediaCell];
        NSString *cellIdentifier = mediaCell.mediaIdentifier;
        
        // select count
        NSInteger selectedIndex = [self.selectedMediaData indexOfMediaWithIdentifier:cellIdentifier];
        [mediaCell setSelectedCountNumber:(selectedIndex + 1) animated:animated];
        mediaCell.disabled = (selectedIndex == -1 && ![self.selectedMediaData canSelectMore]);
        
        // edited image
        BOOL isEdited = [self.mediaModel isEditedWithIndex:indexPath.row];
        if (isEdited)
        {
            mediaCell.imageView.image = [self.mediaModel.editedImageData objectForKey:cellIdentifier];
            mediaCell.infoImageView.image = [ASCWXPickerImageResource imageImage];
        }
    }];
}

- (void)checkButtonStatus
{
    BOOL enableOperation = self.selectedMediaData.count > 0;
    self.previewButton.enabled = enableOperation;
    self.doneButton.enabled = enableOperation;
    self.doneButton.count = self.selectedMediaData.count;
}

@end
