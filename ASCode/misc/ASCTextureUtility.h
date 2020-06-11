//
//  ASCTextureUtility.h
//  ASCode
//
//  Created by Adair Wang on 2020/6/11.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    CGPoint leftTop;
    CGPoint leftBottom;
    CGPoint rightBottom;
    CGPoint rightTop;
} ASCTextureCoordinateInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ASCTextureUtility : NSObject

// camera image: output from AVCaptureVideoDataOutput, which is orientation=LandscapeRight and flip=True
+ (ASCTextureCoordinateInfo)textureCoordinateForDisplayWithCameraImageSize:(CGSize)cameraImageSize
                                                               displaySize:(CGSize)displaySize
                                                        displayOrientation:(UIInterfaceOrientation)displayOrientation
                                                                needMirror:(BOOL)needMirror;

@end

NS_ASSUME_NONNULL_END
