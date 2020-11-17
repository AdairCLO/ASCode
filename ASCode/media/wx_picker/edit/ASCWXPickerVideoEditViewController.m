//
//  ASCWXPickerVideoEditViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerVideoEditViewController.h"
#import "ASCWXPickerTopBarView.h"
#import "ASCWXPickerBottomBarView.h"
#import "ASCWXPickerColorResource.h"
#import "ASCWXPickerImageResource.h"
#import "ASCWXPickerImageButtonListView.h"
#import "ASCWXPickerCaptureResult.h"
#import "ASCWXPickerVideoView.h"
#import <AVFoundation/AVFoundation.h>

// TODO: [edit] video edit: emoji, text, audio, clip

@interface ASCWXPickerVideoEditViewController ()

@property (nonatomic, strong) ASCWXPickerTopBarView *topBarView;
@property (nonatomic, strong) ASCWXPickerBottomBarView *bottomBarView;
@property (nonatomic, strong) ASCWXPickerVideoView *videoView;

@end

@implementation ASCWXPickerVideoEditViewController

@synthesize captureStepPageDelegate = _captureStepPageDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // top bar
    _topBarView = [[ASCWXPickerTopBarView alloc] init];
    _topBarView.translucent = NO;
    [self.view addSubview:_topBarView];
    // top bar - left
    UIButton *topBarViewLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _topBarView.contentHeight, _topBarView.contentHeight)];
    [topBarViewLeftButton setImage:[ASCWXPickerImageResource backImage] forState:UIControlStateNormal];
    [topBarViewLeftButton addTarget:self action:@selector(onBackClicked) forControlEvents:UIControlEventTouchUpInside];
    _topBarView.leftView = topBarViewLeftButton;
    
    // bottom bar
    _bottomBarView = [[ASCWXPickerBottomBarView alloc] initWithContentHeight:76];
    _bottomBarView.translucent = NO;
    [self.view addSubview:_bottomBarView];
    // bottom bar - left
    ASCWXPickerImageButtonListView *imageButtonListView = [[ASCWXPickerImageButtonListView alloc] initWithFrame:CGRectMake(0, 0, 0, _bottomBarView.contentHeight)];
    __weak typeof(self) weakSelf = self;
    ASCWXPickerImageButtonListViewItemClickBlock clickHandler = ^(NSUInteger btnIndex, BOOL isRadio, BOOL isSelected) {
        [weakSelf showOrHidePluginOperationView:btnIndex isRadio:isRadio isSelected:isSelected];
    };
    imageButtonListView.items = @[
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource videoEditEmojiImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource videoEditTextImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource videoEditAudioImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource videoEditClipImage] clickHandler:clickHandler],
    ];
    _bottomBarView.leftView = imageButtonListView;
    // bottom bar - right
    UIButton *bottomBarViewRightButton = [[UIButton alloc] init];
    bottomBarViewRightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [bottomBarViewRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomBarViewRightButton setTitle:@"完成" forState:UIControlStateNormal];
    [bottomBarViewRightButton addTarget:self action:@selector(onDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    bottomBarViewRightButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    bottomBarViewRightButton.layer.cornerRadius = 3;
    bottomBarViewRightButton.backgroundColor = [ASCWXPickerColorResource themeColor];
    [bottomBarViewRightButton sizeToFit];
    _bottomBarView.rightView = bottomBarViewRightButton;
    
    _videoView = [[ASCWXPickerVideoView alloc] initWithFrame:self.view.bounds];
    _videoView.videoURL = self.videoURL;
    _videoView.loopEnabled = YES;
    _videoView.tapToTogglePlaybackStatusEnabled = NO;
    [_videoView play];
    [self.view insertSubview:_videoView atIndex:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // plugins
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoView pause];
}

#pragma mark - button

- (void)onBackClicked
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onDoneClicked
{
    // TODO: if need save the capture image/video?? or config to decide to save or not
    
    ASCWXPickerCaptureResult *result = [[ASCWXPickerCaptureResult alloc] init];
    result.videoURL = self.videoURL;
    [self.captureStepPageDelegate captureStepPage:self didFinishCapturing:result];
}

- (void)showOrHidePluginOperationView:(NSUInteger)index isRadio:(BOOL)isRadio isSelected:(BOOL)isSelected
{
    
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
