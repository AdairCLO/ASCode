//
//  ASCWXPickerImageEditViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerImageEditViewController.h"
#import "ASCWXPickerTopBarView.h"
#import "ASCWXPickerBottomBarView.h"
#import "ASCWXPickerColorResource.h"
#import "ASCWXPickerImageResource.h"
#import "ASCWXPickerImageButtonListView.h"
#import "ASCWXPickerCaptureResult.h"
#import "ASCWXPickerLoadingViewController.h"
#import "ASCWXPickerDrawEditPlugin.h"
#import "ASCWXPickerTextEditPlugin.h"
#import "ASCWXPickerContentContainerView.h"
#import "ASCWXPickerContentContainerViewManager.h"
#import "ASCWXPickerOccludeView.h"
#import "ASCWXPickerDeleteView.h"

// TODO: [edit] image edit: emoji, crop, mosaic

@interface ASCWXPickerImageEditViewController ()

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ASCWXPickerTopBarView *topBarView;
@property (nonatomic, strong) ASCWXPickerBottomBarView *bottomBarView;
@property (nonatomic, strong) UIScrollView *containerScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *pluginOperationView;
@property (nonatomic, strong) UIView *pluginContentContainerView;
@property (nonatomic, strong) NSDictionary<NSString *, id<ASCWXPickerEditPluginProtocol>> *plugins;
@property (nonatomic, assign) CGSize pluginContentDisplaySize;
@property (nonatomic, strong) ASCWXPickerContentContainerViewManager *contentContainerViewManager;
@property (nonatomic, strong) ASCWXPickerOccludeView *occludeView;
@property (nonatomic, strong) ASCWXPickerDeleteView *deleteView;

@end

@implementation ASCWXPickerImageEditViewController

@synthesize captureStepPageDelegate = _captureStepPageDelegate;

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        assert(image.size.width > 0 && image.size.height > 0);
        _image = image;
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assert(_image.size.width > 0 && _image.size.height > 0);
    
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
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource imageEditDrawImage] selectedImage:[ASCWXPickerImageResource imageEditSelectedDrawImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource imageEditEmojiImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource imageEditTextImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource imageEditCropImage] clickHandler:clickHandler],
        [ASCWXPickerImageButtonListViewItem itemWithImage:[ASCWXPickerImageResource imageEditMosaicImage] selectedImage:[ASCWXPickerImageResource imageEditSelectedMosaicImage] clickHandler:clickHandler],
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

    _containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    CGSize imageSize = _image.size;
    _pluginContentDisplaySize = CGSizeMake(self.view.frame.size.width, floor(imageSize.height / imageSize.width * self.view.frame.size.width));
    
    // image
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _pluginContentDisplaySize.width, MAX(_pluginContentDisplaySize.height, _containerScrollView.frame.size.height))];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = _image;
    
    if (@available(iOS 11.0, *)) {
        _containerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _containerScrollView.contentSize = _imageView.frame.size;
    _containerScrollView.showsVerticalScrollIndicator = NO;
    [_containerScrollView addSubview:_imageView];
    [self.view insertSubview:_containerScrollView atIndex:0];
    
    // plugins - container view
    _pluginContentContainerView = [[UIView alloc] initWithFrame:_imageView.frame];
    [_containerScrollView addSubview:_pluginContentContainerView];
    
    // plugins - operation view
    _pluginOperationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    
    _contentContainerViewManager = [[ASCWXPickerContentContainerViewManager alloc] initWithParentView:_pluginContentContainerView];
    
    [self setupPlugins];
    
    CGFloat occludeHeight = 0;
    if (_pluginContentDisplaySize.height < self.view.bounds.size.height)
    {
        occludeHeight = (self.view.bounds.size.height - _pluginContentDisplaySize.height) / 2;
    }
    _occludeView = [[ASCWXPickerOccludeView alloc] initWithFrame:self.view.bounds];
    _occludeView.occludeColor = [UIColor blackColor];
    _occludeView.topOccludeHeight = occludeHeight;
    _occludeView.bottomOccludeHeight = occludeHeight;
    _occludeView.userInteractionEnabled = NO;
    [self.view insertSubview:_occludeView aboveSubview:_containerScrollView];
    
    _deleteView = [[ASCWXPickerDeleteView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 160) / 2, self.view.frame.size.height, 160, 80)];
    [self.view insertSubview:_deleteView aboveSubview:_occludeView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupPlugins
{
    if (_plugins != nil)
    {
        return;
    }
    
    CGSize contentDisplaySize = self.pluginContentDisplaySize;
    __weak typeof(self) weakSelf = self;
    
    // draw
    ASCWXPickerDrawEditPlugin *drawEditPlugin = [[ASCWXPickerDrawEditPlugin alloc] init];
    drawEditPlugin.contentDisplaySize = contentDisplaySize;
    drawEditPlugin.contentDidAddHandler = ^(UIView * _Nonnull content) {
        content.center = weakSelf.pluginContentContainerView.center;
        [weakSelf.pluginContentContainerView insertSubview:content atIndex:0];
    };
    drawEditPlugin.editStateChangedHandler = ^(BOOL isEditing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarViews) object:nil];
        
        if (isEditing)
        {
            [weakSelf hideBarViews];
        }
        else
        {
            [weakSelf performSelector:@selector(showBarViews) withObject:nil afterDelay:0.8];
        }
    };
    
    // text
    ASCWXPickerTextEditPlugin *textEditPlugin = [[ASCWXPickerTextEditPlugin alloc] init];
    __weak ASCWXPickerTextEditPlugin *weakTextEditPlugin = textEditPlugin;
    textEditPlugin.contentDisplaySize = contentDisplaySize;
    textEditPlugin.contentDidAddHandler = ^(UIView * _Nonnull content) {
        ASCWXPickerContentContainerView *container = [[ASCWXPickerContentContainerView alloc] init];
        container.contentView = content;
        container.center = CGPointMake(weakSelf.containerScrollView.frame.size.width / 2, weakSelf.containerScrollView.contentOffset.y + weakSelf.containerScrollView.frame.size.height / 2);
        container.tapHandler = ^(ASCWXPickerContentContainerView *contentContainerView){
            if ([contentContainerView isActive])
            {
                [weakTextEditPlugin presentOperationPageWithContainerVC:weakSelf withContentView:contentContainerView.contentView];
            }
            else
            {
                [weakSelf.contentContainerViewManager activeView:contentContainerView autoDeactive:YES];
            }
        };
        container.transformBeganHandler = ^(ASCWXPickerContentContainerView *contentContainerView) {
            [weakSelf startMovingContent];
            [weakSelf.contentContainerViewManager putViewToTop:contentContainerView];
            [weakSelf.contentContainerViewManager activeView:contentContainerView autoDeactive:NO];
        };
        container.transformMovedHandler = ^(ASCWXPickerContentContainerView *contentContainerView) {
            [weakSelf checkDeletePosition:contentContainerView];
        };
        container.transformEndedHandler = ^(ASCWXPickerContentContainerView *contentContainerView) {
            [weakSelf endMovingContent];
            if (weakSelf.deleteView.deleteMode)
            {
                [contentContainerView removeFromSuperview];
            }
            else
            {
                [weakSelf confirmContentViewPosition:contentContainerView];
                [weakSelf.contentContainerViewManager activeView:contentContainerView autoDeactive:YES];
            }
        };
        [weakSelf.pluginContentContainerView addSubview:container];
        [weakSelf.contentContainerViewManager activeView:container autoDeactive:YES];
    };
    textEditPlugin.contentDidRemoveHandler = ^(UIView * _Nonnull content) {
        ASCWXPickerContentContainerView *container = (ASCWXPickerContentContainerView *)content.superview;
        if (![container isKindOfClass:[ASCWXPickerContentContainerView class]])
        {
            return;
        }
        [container removeFromSuperview];
    };
    textEditPlugin.contentDidUpdateHandler = ^(UIView * _Nonnull content) {
        ASCWXPickerContentContainerView *container = (ASCWXPickerContentContainerView *)content.superview;
        if (![container isKindOfClass:[ASCWXPickerContentContainerView class]])
        {
            return;
        }
        container.contentView = content;
        [weakSelf.contentContainerViewManager activeView:container autoDeactive:YES];
    };
    textEditPlugin.editStateChangedHandler = ^(BOOL isEditing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarViews) object:nil];
        
        if (isEditing)
        {
            [weakSelf hideBarViews];
        }
        else
        {
            [weakSelf showBarViews];
        }
    };
    
    _plugins = @{ @"0": drawEditPlugin, @"2": textEditPlugin };
}

#pragma mark - button

- (void)onBackClicked
{
    [self.delegate imageEditVCWillClose:self];
}

- (void)onDoneClicked
{
    __block BOOL edited = NO;
    [self.pluginContentContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([v conformsToProtocol:@protocol(ASCWXPickerEditPluginContentProtocol)])
        {
            edited = [((id<ASCWXPickerEditPluginContentProtocol>)v) hasEditedContent];
        }
        else
        {
            edited = YES;
        }
        if (edited)
        {
            *stop = YES;
        }
    }];
    
    if (!edited)
    {
        [self completeEditWithImage:self.image editedImage:nil];
        return;
    }
    
    // prepare for rendering
    [self.pluginContentContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([v conformsToProtocol:@protocol(ASCWXPickerEditPluginContentProtocol)])
        {
            [((id<ASCWXPickerEditPluginContentProtocol>)v) prepareForRendering];
        }
    }];
    
    // start to generate the edited image
    ASCWXPickerLoadingViewController *loadingVC = [[ASCWXPickerLoadingViewController alloc] init];
    [self presentViewController:loadingVC animated:NO completion:nil];
    
    CGSize containerSize = self.pluginContentContainerView.frame.size;
    CGSize drawSize = self.pluginContentDisplaySize;
    CALayer *drawLayer = self.pluginContentContainerView.layer;
//    NSArray<CALayer *> *drawLayers = [drawLayer.sublayers sortedArrayUsingComparator:^NSComparisonResult(CALayer * _Nonnull obj1, CALayer * _Nonnull obj2) {
//        if (obj1.zPosition <= obj2.zPosition)
//        {
//            return NSOrderedDescending;
//        }
//        return NSOrderedAscending;
//    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGSize size = self.image.size;
        UIGraphicsBeginImageContextWithOptions(size, YES, self.image.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIGraphicsPushContext(context);
        [self.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIGraphicsPopContext();
        
        UIGraphicsPushContext(context);
        CGFloat scale = self.image.size.width / drawSize.width;
        CGContextScaleCTM(context, scale, scale);
        CGContextTranslateCTM(context, -((containerSize.width - drawSize.width) / 2), -((containerSize.height - drawSize.height) / 2));
        [drawLayer renderInContext:context];
        
        // note:
        // - draw sublayers is better than draw the "container": draw line at the image edge...... because the floating-point number precision???
        // - but, 'draw the "container"' method is more simple......
//        [drawLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull l, NSUInteger idx, BOOL * _Nonnull stop) {
//            [l renderInContext:context];
//        }];
        UIGraphicsPopContext();
        
        UIImage *editedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingVC dismissViewControllerAnimated:NO completion:^{
                [self completeEditWithImage:self.image editedImage:editedImage];
            }];
        });
    });
}

- (void)completeEditWithImage:(UIImage *)image editedImage:(UIImage *)editedImage
{
    [self.delegate imageEidtVC:self didCompleteWithEditedImage:editedImage];
    
    // TODO: if need save the capture image/video?? or config to decide to save or not
    
    ASCWXPickerCaptureResult *result = [[ASCWXPickerCaptureResult alloc] init];
    result.image = editedImage ?: image;
    [self.captureStepPageDelegate captureStepPage:self didFinishCapturing:result];
}

- (void)showOrHidePluginOperationView:(NSUInteger)index isRadio:(BOOL)isRadio isSelected:(BOOL)isSelected
{
    NSString *pluginKey = [NSString stringWithFormat:@"%zd", index];
    id<ASCWXPickerEditPluginProtocol> plugin = [self.plugins objectForKey:pluginKey];
    
    if (isRadio)
    {
        if (isSelected)
        {
            // hide other before show
            [self.plugins enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<ASCWXPickerEditPluginProtocol>  _Nonnull p, BOOL * _Nonnull stop) {
                [p hideOperationView];
            }];
            
            // show
            CGFloat pluginOperationViewHeight = [plugin showOperationViewInContainerView:self.pluginOperationView];
            self.pluginOperationView.frame = CGRectMake(0, 0, self.view.frame.size.width, pluginOperationViewHeight);
            self.bottomBarView.topView = self.pluginOperationView;
        }
        else
        {
            // hide
            [plugin hideOperationView];
            self.bottomBarView.topView = nil;
        }
    }
    else
    {
        [plugin presentOperationPageWithContainerVC:self withContentView:nil];
    }
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
    
    // cancel delay show by plugins
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarViews) object:nil];
    
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

- (void)startMovingContent
{
    [self hideBarViews];
    
    self.occludeView.hidden = YES;
    
    self.deleteView.alpha = 1;
    self.deleteView.frame = CGRectMake((self.view.frame.size.width - self.deleteView.frame.size.width) / 2, self.view.frame.size.height, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
    [UIView animateWithDuration:0.15 animations:^{
        self.deleteView.frame = CGRectMake((self.view.frame.size.width - self.deleteView.frame.size.width) / 2, self.view.frame.size.height - self.deleteView.frame.size.height - 20, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
    }];
}

- (void)endMovingContent
{
    [self showBarViews];
    
    self.occludeView.hidden = NO;
    
    [UIView animateWithDuration:0.15 animations:^{
        self.deleteView.alpha = 0;
    }];
}

- (void)confirmContentViewPosition:(ASCWXPickerContentContainerView *)contentContainerView
{
    BOOL resetPosition = (self.occludeView.topOccludeHeight > 0 && CGRectGetMaxY(contentContainerView.frame) <= self.occludeView.topOccludeHeight)
                            || (self.occludeView.bottomOccludeHeight > 0 && CGRectGetMinY(contentContainerView.frame) >= (self.occludeView.frame.size.height - self.occludeView.bottomOccludeHeight));
    if (resetPosition)
    {
        [UIView animateWithDuration:0.15 animations:^{
            [contentContainerView resetTranslateTransform];
        }];
    }
}

- (void)checkDeletePosition:(ASCWXPickerContentContainerView *)contentContainerView
{
    CGPoint pointInDeleteView = [self.deleteView convertPoint:contentContainerView.transformTouchPointInView fromView:contentContainerView];
    self.deleteView.deleteMode = CGRectContainsPoint(self.deleteView.bounds, pointInDeleteView);
}

@end
