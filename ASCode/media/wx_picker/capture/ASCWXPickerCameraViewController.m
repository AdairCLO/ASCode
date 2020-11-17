//
//  ASCWXPickerCameraViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/21.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ASCWXPickerCaptureButton.h"
#import "ASCWXPickerImageResource.h"
#import "ASCWXPickerImageEditViewController.h"
#import "ASCWXPickerVideoEditViewController.h"
#import "ASCWXPickerInterfaceOrientationManager.h"

static const CGFloat kButtonSize = 36;
static const CGFloat kButtonImageSize = 24;
static const CGFloat kButtonContentEdgeInsets = (kButtonSize - kButtonImageSize) / 2;

typedef NS_ENUM(NSInteger, ASCWXPickerCameraViewControllerCaptureState) {
    ASCWXPickerCameraViewControllerCaptureStateNone,
    ASCWXPickerCameraViewControllerCaptureStateCaptureImage,
    ASCWXPickerCameraViewControllerCaptureStateCaptureVideo,
};

@interface ASCWXPickerCameraViewController () <ASCWXPickerCaptureButtonDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, ASCWXPickerImageEditViewControllerDelegate>

@property (nonatomic, strong) UIButton *cameraSwitchButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) ASCWXPickerCaptureButton *captureButton;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic, strong) AVCapturePhotoOutput *capturePhotoOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic, strong) NSURL *videoOuputFileURL;
@property (nonatomic, assign) BOOL saveVideoOutput;
@property (nonatomic, strong) UIView *photoCaptureBackgroundView;
@property (nonatomic, assign) ASCWXPickerCameraViewControllerCaptureState captureState;

@property (nonatomic, strong) ASCWXPickerInterfaceOrientationManager *interfaceOrientationManager;

@end

@implementation ASCWXPickerCameraViewController

@synthesize captureStepPageDelegate = _captureStepPageDelegate;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _captureState = ASCWXPickerCameraViewControllerCaptureStateNone;
        _interfaceOrientationManager = [[ASCWXPickerInterfaceOrientationManager alloc] initWithOrientation:UIInterfaceOrientationPortrait];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterfaceOrientationManagerOrientationDidChangeNotification) name:ASCWXPickerInterfaceOrientationManagerOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _photoCaptureBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _photoCaptureBackgroundView.backgroundColor = [UIColor blackColor];
    _photoCaptureBackgroundView.alpha = 0;
    _photoCaptureBackgroundView.hidden = YES;
    [self.view addSubview:_photoCaptureBackgroundView];
    
    _cameraSwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kButtonSize - 20, 28, kButtonSize, kButtonSize)];
    _cameraSwitchButton.contentEdgeInsets = UIEdgeInsetsMake(kButtonContentEdgeInsets, kButtonContentEdgeInsets, kButtonContentEdgeInsets, kButtonContentEdgeInsets);
    [_cameraSwitchButton setImage:[ASCWXPickerImageResource cameraSwitchImage] forState:UIControlStateNormal];
    [_cameraSwitchButton addTarget:self action:@selector(onCameraSwitchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraSwitchButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(60, self.view.frame.size.height - kButtonSize - 44, kButtonSize, kButtonSize)];
    _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(kButtonContentEdgeInsets, kButtonContentEdgeInsets, kButtonContentEdgeInsets, kButtonContentEdgeInsets);
    [_cancelButton setImage:[ASCWXPickerImageResource cameraCancelImage] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(onCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    
    _captureButton = [[ASCWXPickerCaptureButton alloc] init];
    _captureButton.frame = CGRectMake((self.view.frame.size.width - _captureButton.frame.size.width) / 2, self.view.frame.size.height - _captureButton.frame.size.height - 8, _captureButton.frame.size.width, _captureButton.frame.size.height);
    _captureButton.delegate = self;
    [self.view addSubview:_captureButton];
    
    // TODO: [capture] ui detail: info text; camera function: focus rect
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // ----------------------------------------------
    // cpature session
    _captureSession = [[AVCaptureSession alloc] init];
    // default: AVCaptureSessionPresetHigh, 1920*1080
    // AVCaptureSessionPreset1920x1080
    // AVCaptureSessionPreset640x480
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // input
    AVCaptureDevice *videoDevice = [self defaultCameraDevice];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    if ([_captureSession canAddInput:videoDeviceInput])
    {
        [_captureSession addInput:videoDeviceInput];
    }
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if ([_captureSession canAddInput:audioDeviceInput])
    {
        [_captureSession addInput:audioDeviceInput];
    }
    
    // output
    _capturePhotoOutput = [[AVCapturePhotoOutput alloc] init];
    _capturePhotoOutput.livePhotoCaptureEnabled = NO;
    _capturePhotoOutput.highResolutionCaptureEnabled = NO;
//    _capturePhotoOutput.depthDataDeliveryEnabled = NO;
    if ([_captureSession canAddOutput:_capturePhotoOutput])
    {
        [_captureSession addOutput:_capturePhotoOutput];
    }
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([_captureSession canAddOutput:_captureMovieFileOutput])
    {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    
    // preview
    _capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _capturePreviewLayer.frame = self.view.bounds;
    _capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer insertSublayer:_capturePreviewLayer atIndex:0];
    
    // TODO: [capture] start/stop capture session; first appear problem...
    [self startCaptureSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.interfaceOrientationManager startUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.interfaceOrientationManager stopUpdate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self resetState];
}

- (void)setCaptureState:(ASCWXPickerCameraViewControllerCaptureState)captureState
{
    _captureState = captureState;
    
    if (_captureState == ASCWXPickerCameraViewControllerCaptureStateNone)
    {
        self.view.userInteractionEnabled = YES;
    }
    else if (_captureState == ASCWXPickerCameraViewControllerCaptureStateCaptureImage)
    {
        self.view.userInteractionEnabled = NO;
    }
    else if (_captureState == ASCWXPickerCameraViewControllerCaptureStateCaptureVideo)
    {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)startCaptureSession
{
#if !TARGET_IPHONE_SIMULATOR
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
#endif
}

- (void)stopCaptureSession
{
#if !TARGET_IPHONE_SIMULATOR
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession stopRunning];
    });
#endif
}

- (void)updateVideoOrientationForCaptureOutput:(AVCaptureOutput *)captureOutput
{
    AVCaptureConnection *connection = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported)
    {
        connection.videoOrientation = [self currentVideoOrientation];
    }
}

- (AVCaptureVideoOrientation)currentVideoOrientation
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientationManager.currentOrientation;
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    return videoOrientation;
}

- (AVCaptureDeviceInput *)activeCameraDeviceInput
{
    __block AVCaptureDeviceInput *activeInput = nil;
    
    [self.captureSession.inputs enumerateObjectsUsingBlock:^(__kindof AVCaptureInput * _Nonnull input, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([input isKindOfClass:[AVCaptureDeviceInput class]])
        {
            AVCaptureDeviceInput *deviceInput = (AVCaptureDeviceInput *)input;
            if ([deviceInput.device hasMediaType:AVMediaTypeVideo])
            {
                activeInput = deviceInput;
                *stop = YES;
            }
        }
    }];
    
    return activeInput;
}

- (AVCaptureDevice *)activeCameraDevice
{
    return [self activeCameraDeviceInput].device;
}

- (AVCaptureDevice *)defaultCameraDevice
{
    // TODO: [capture] backend camera: try to use dual/triple camera; frontend camera: try to use true depth camera
    return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)anotherCameraDevice
{
    AVCaptureDevice *activeDevice = [self activeCameraDevice];
    if (activeDevice == nil)
    {
        return [self defaultCameraDevice];
    }
    
    AVCaptureDevicePosition currentPosition = activeDevice.position;
    AVCaptureDevicePosition targetPosition = ((currentPosition == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack);
    return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:targetPosition];
}

- (void)resetState
{
    self.captureState = ASCWXPickerCameraViewControllerCaptureStateNone;
    self.saveVideoOutput = NO;
}

#pragma mark - button

- (void)onCameraSwitchButtonClicked
{
    AVCaptureDevice *targetVideoDevice = [self anotherCameraDevice];
    if (targetVideoDevice != nil)
    {
        [self.captureSession beginConfiguration];
        
        AVCaptureDeviceInput *currentVideoDeviceInput = [self activeCameraDeviceInput];
        [self.captureSession removeInput:currentVideoDeviceInput];
        AVCaptureDeviceInput *targetVideoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:targetVideoDevice error:nil];
        if ([self.captureSession canAddInput:targetVideoDeviceInput])
        {
            [self.captureSession addInput:targetVideoDeviceInput];
        }
        else
        {
            [self.captureSession addInput:currentVideoDeviceInput];
        }
        
        [self.captureSession commitConfiguration];
    }
}

- (void)onCancelButtonClicked
{
    [self.captureStepPageDelegate captureStepPage:self didFinishCapturing:nil];
}

#pragma mark - notification

- (void)onInterfaceOrientationManagerOrientationDidChangeNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.cameraSwitchButton.transform = [self affineTransformFromOrientation:self.interfaceOrientationManager.currentOrientation];
    }];
}

- (CGAffineTransform)affineTransformFromOrientation:(UIInterfaceOrientation)interfaceOrienation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (interfaceOrienation == UIInterfaceOrientationLandscapeLeft)
    {
        transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else if (interfaceOrienation == UIInterfaceOrientationLandscapeRight)
    {
        transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if (interfaceOrienation == UIInterfaceOrientationPortraitUpsideDown)
    {
        transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    return transform;
}

#pragma mark - ASCWXPickerCaptureButtonDelegate

- (void)captureButtonDidCaptureImage:(ASCWXPickerCaptureButton *)button
{
    self.captureState = ASCWXPickerCameraViewControllerCaptureStateCaptureImage;
    
    [self updateVideoOrientationForCaptureOutput:self.capturePhotoOutput];

#if !TARGET_IPHONE_SIMULATOR
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    [self.capturePhotoOutput capturePhotoWithSettings:settings delegate:self];
#else
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.captureState = ASCWXPickerCameraViewControllerCaptureStateNone;
        
        CGSize size = self.view.frame.size;
//        BOOL isHorizontal = YES;
//        if (isHorizontal)
//        {
//            size = CGSizeMake(size.height, size.width);
//        }
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
        [[UIColor orangeColor] setFill];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
        [bezierPath fill];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        ASCWXPickerImageEditViewController *imageEditVC = [[ASCWXPickerImageEditViewController alloc] initWithImage:image];
        imageEditVC.delegate = self;
        [self.navigationController pushViewController:imageEditVC animated:NO];
    });
#endif
    
    // capture image animation
    self.photoCaptureBackgroundView.alpha = 1;
    self.photoCaptureBackgroundView.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.photoCaptureBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        self.photoCaptureBackgroundView.hidden = YES;
    }];
}

- (void)captureButtonDidStartCaptureVideo:(ASCWXPickerCaptureButton *)button
{
#if !TARGET_IPHONE_SIMULATOR
    self.captureState = ASCWXPickerCameraViewControllerCaptureStateCaptureVideo;
    
    NSString *tempFileName = [NSString stringWithFormat:@"%@.MOV", [NSUUID UUID].UUIDString];
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];
    NSURL *tempFile = [NSURL fileURLWithPath:tempFilePath];
    [self.captureMovieFileOutput startRecordingToOutputFileURL:tempFile recordingDelegate:self];
#endif
}

- (void)captureButtonDidStopCaptureVideo:(ASCWXPickerCaptureButton *)button
{
#if !TARGET_IPHONE_SIMULATOR
    self.captureState = ASCWXPickerCameraViewControllerCaptureStateNone;
    
    self.saveVideoOutput = YES;
    [self.captureMovieFileOutput stopRecording];
#endif
}

- (void)captureButtonDidCancelCaptureVideo:(ASCWXPickerCaptureButton *)button
{
#if !TARGET_IPHONE_SIMULATOR
    self.captureState = ASCWXPickerCameraViewControllerCaptureStateNone;
    
    self.saveVideoOutput = NO;
    [self.captureMovieFileOutput stopRecording];
#endif
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error
{
    self.captureState = ASCWXPickerCameraViewControllerCaptureStateNone;
    
    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:data];
    
    ASCWXPickerImageEditViewController *imageEditVC = [[ASCWXPickerImageEditViewController alloc] initWithImage:image];
    imageEditVC.delegate = self;
    [self.navigationController pushViewController:imageEditVC animated:NO];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error
{
    if (self.saveVideoOutput && error == nil)
    {
        ASCWXPickerVideoEditViewController *videoEditVC = [[ASCWXPickerVideoEditViewController alloc] init];
        videoEditVC.videoURL = outputFileURL;
        [self.navigationController pushViewController:videoEditVC animated:NO];
    }
    else
    {
        // remove the video output file
        [[NSFileManager defaultManager] removeItemAtPath:outputFileURL.path error:nil];
    }
}

#pragma mark - ASCWXPickerImageEditViewControllerDelegate

- (void)imageEidtVC:(ASCWXPickerImageEditViewController *)imageEditVC didCompleteWithEditedImage:(UIImage *)editedImage;
{
    // do nothing
}

- (void)imageEditVCWillClose:(ASCWXPickerImageEditViewController *)imageEditVC
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
