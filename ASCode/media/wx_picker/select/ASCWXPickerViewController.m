//
//  ASCWXPickerViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/12.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerViewController.h"
#import "ASCWXPickerContentViewController.h"
#import "ASCWXPickerStepPageProtocol.h"

@interface ASCWXPickerViewController () <UINavigationControllerDelegate, ASCWXPickerStepPageDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation ASCWXPickerViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // TODO: privacy (use and add? to photo library) query and check
        
        ASCWXPickerContentViewController *rootViewController = [[ASCWXPickerContentViewController alloc] init];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
    if ([viewController conformsToProtocol:@protocol(ASCWXPickerStepPageProtocol)])
    {
        id<ASCWXPickerStepPageProtocol> pickerStepPage = (id<ASCWXPickerStepPageProtocol>)viewController;
        pickerStepPage.pickerStepPageDelegate = self;
    }
}

#pragma mark - ASCWXPickerStepPageDelegate

- (void)pickerStepPage:(id<ASCWXPickerStepPageProtocol>)page didFinishPicking:(NSArray<ASCWXPickerResult *> *)results
{
    [self.delegate ascWXPicer:self didFinishPicking:results];
}

@end
