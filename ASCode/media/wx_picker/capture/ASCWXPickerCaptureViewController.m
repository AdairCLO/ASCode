//
//  ASCWXPickerCaptureViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerCaptureViewController.h"
#import "ASCWXPickerCameraViewController.h"
#import "ASCWXPickerCaptureStepPageProtocol.h"

@interface ASCWXPickerCaptureViewController () <UINavigationControllerDelegate, ASCWXPickerCaptureStepPageDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation ASCWXPickerCaptureViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // TODO: privacy (use camera and microphone) query and check
        
        ASCWXPickerCameraViewController *rootViewController = [[ASCWXPickerCameraViewController alloc] init];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        _navigationController.delegate = self;
        
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:_navigationController];
    [self.view addSubview:_navigationController.view];
    [_navigationController didMoveToParentViewController:self];
    
    _navigationController.navigationBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController conformsToProtocol:@protocol(ASCWXPickerCaptureStepPageProtocol)])
    {
        id<ASCWXPickerCaptureStepPageProtocol> captureStepPage = (id<ASCWXPickerCaptureStepPageProtocol>)viewController;
        captureStepPage.captureStepPageDelegate = self;
    }
}

#pragma mark - ASCWXPickerCaptureStepPageDelegate

- (void)captureStepPage:(id<ASCWXPickerCaptureStepPageProtocol>)page didFinishCapturing:(ASCWXPickerCaptureResult *)result
{
    [self.delegate ascWXPicerCaptureVC:self didFinishCapturing:result];
}

@end
