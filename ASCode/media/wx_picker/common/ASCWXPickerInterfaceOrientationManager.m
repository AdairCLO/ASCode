//
//  ASCWXPickerInterfaceOrientationManager.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/24.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerInterfaceOrientationManager.h"
#import <CoreMotion/CoreMotion.h>

NSString * const ASCWXPickerInterfaceOrientationManagerOrientationDidChangeNotification = @"ASCWXPickerInterfaceOrientationManagerOrientationDidChangeNotification";

@interface ASCWXPickerInterfaceOrientationManager ()

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@end

@implementation ASCWXPickerInterfaceOrientationManager

- (instancetype)initWithOrientation:(UIInterfaceOrientation)orientation
{
    self = [super init];
    if (self)
    {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        
        _currentOrientation = orientation;
    }
    return self;
}

- (void)dealloc
{
    [self stopUpdate];
}

- (void)startUpdate
{
    if (!self.motionManager.isAccelerometerAvailable)
    {
        return;
    }
    
    if (self.motionManager.isAccelerometerActive)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        if (error == nil)
        {
            [weakSelf updateOrientationWithAccelerometerData:accelerometerData];
        }
    }];
}

- (void)stopUpdate
{
    if (!self.motionManager.isAccelerometerActive)
    {
        return;
    }
    
    [self.motionManager stopAccelerometerUpdates];
}

- (void)updateOrientationWithAccelerometerData:(CMAccelerometerData *)accelerometerData
{
    if (accelerometerData == nil)
    {
        return;
    }
    
    float z = accelerometerData.acceleration.z;
    if (ABS(z) < 0.85)
    {
        float x = accelerometerData.acceleration.x;
        float y = accelerometerData.acceleration.y;
        float angle = atan2(y, x);
        
        UIInterfaceOrientation newInterfaceOrientation = UIInterfaceOrientationUnknown;
        UIInterfaceOrientation oldInterfaceOrientation = self.currentOrientation;
        if (oldInterfaceOrientation != UIInterfaceOrientationUnknown)
        {
            // 0.52: 30 degree
            // 2.62: 150 degree
            
            // 1.05: 60 degree
            // 2.09 : 120 degree
            
            if(angle >= -2.09 && angle <= -1.05) {
                newInterfaceOrientation = UIInterfaceOrientationPortrait;
            } else if(angle >= -0.52 && angle <= 0.52){
                newInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            } else if(angle >= 1.05 && angle <= 2.09) {
                newInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            } else if(angle <= -2.62 || angle >= 2.62) {
                newInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
            }
        }
        else
        {
            // 0.79: 45 degree
            // 2.36: 135 degree
            
            if(angle >= -2.36 && angle <= -0.79) {
                newInterfaceOrientation = UIInterfaceOrientationPortrait;
            } else if(angle >= -0.79 && angle <= 0.79){
                newInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            } else if(angle >= 0.79 && angle <= 2.36) {
                newInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            } else if(angle <= -2.36 || angle >= 2.36) {
                newInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
            }
        }
        
        if (newInterfaceOrientation != UIInterfaceOrientationUnknown && oldInterfaceOrientation != newInterfaceOrientation)
        {
            self.currentOrientation = newInterfaceOrientation;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ASCWXPickerInterfaceOrientationManagerOrientationDidChangeNotification object:nil];
        }
    }
}

@end
