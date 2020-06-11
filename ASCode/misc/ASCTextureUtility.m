//
//  ASCTextureUtility.m
//  ASCode
//
//  Created by Adair Wang on 2020/6/11.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCTextureUtility.h"

@implementation ASCTextureUtility

+ (ASCTextureCoordinateInfo)textureCoordinateForDisplayWithCameraImageSize:(CGSize)cameraImageSize
                                                               displaySize:(CGSize)displaySize
                                                        displayOrientation:(UIInterfaceOrientation)displayOrientation
                                                                needMirror:(BOOL)needMirror
{
    ASCTextureCoordinateInfo textureCoordInfo;
    textureCoordInfo.leftTop = CGPointZero;
    textureCoordInfo.leftBottom = CGPointZero;
    textureCoordInfo.rightBottom = CGPointZero;
    textureCoordInfo.rightTop = CGPointZero;

    if (cameraImageSize.width == 0 || cameraImageSize.height == 0 || displaySize.width == 0 || displaySize.height == 0)
    {
        return textureCoordInfo;
    }
    if (displayOrientation == UIInterfaceOrientationUnknown)
    {
        return textureCoordInfo;
    }
    
    // 1. get the coordinate of "camera" with scaling to "display"
    // s_min/s_max/t_min/t_max are texture coordinates in the "camera image" orientation, whick is landscape right(home button is on the right side)
    CGFloat s_min = 0;
    CGFloat s_max = 0;
    CGFloat t_min = 0;
    CGFloat t_max = 0;
    
    CGFloat displayRatio = displaySize.width / displaySize.height;
    // contentWidth and contentHeight are in the orientation of the display
    CGFloat contentWidth = 0;
    CGFloat contentHeight = 0;
    BOOL isDisplayPortrait = UIInterfaceOrientationIsPortrait(displayOrientation);
    if (isDisplayPortrait)
    {
        contentWidth = cameraImageSize.height;
        contentHeight = cameraImageSize.width;
    }
    else
    {
        contentWidth = cameraImageSize.width;
        contentHeight = cameraImageSize.height;
    }
    CGFloat contentRatio = contentWidth / contentHeight;
    
    if (displayRatio == contentRatio)
    {
        s_min = 0;
        s_max = 1;
        t_min = 0;
        t_max = 1;
    }
    else if (displayRatio > contentRatio)
    {
        CGFloat newContentHeight = displaySize.width / contentRatio;
        CGFloat diff = (newContentHeight - displaySize.height) / newContentHeight / 2;

        if (isDisplayPortrait)
        {
            s_min = diff;
            s_max = 1 - diff;
            t_min = 0;
            t_max = 1;
        }
        else
        {
            s_min = 0;
            s_max = 1;
            t_min = diff;
            t_max = 1 - diff;
        }
    }
    else
    {
        CGFloat newContentWidth = displaySize.height * contentRatio;
        CGFloat diff = (newContentWidth - displaySize.width) / newContentWidth / 2;

        if (isDisplayPortrait)
        {
            s_min = 0;
            s_max = 1;
            t_min = diff;
            t_max = 1 - diff;
        }
        else
        {
            s_min = diff;
            s_max = 1 - diff;
            t_min = 0;
            t_max = 1;
        }
    }
    
    // 2. flip and mirror
    // "camera image" is flip=True
    // if need mirror, no need to do any operation about flip: the flip and mirror just cancel out
    if (!needMirror)
    {
        CGFloat temp_t_min = t_min;
        t_min = t_max;
        t_max = temp_t_min;
    }
    
    // 3. map the coordinate from "camera" to "display"
    if (displayOrientation == UIInterfaceOrientationPortrait)
    {
        textureCoordInfo.leftTop.x = s_min;
        textureCoordInfo.leftTop.y = t_min;
        textureCoordInfo.leftBottom.x = s_max;
        textureCoordInfo.leftBottom.y = t_min;
        textureCoordInfo.rightBottom.x = s_max;
        textureCoordInfo.rightBottom.y = t_max;
        textureCoordInfo.rightTop.x = s_min;
        textureCoordInfo.rightTop.y = t_max;
    }
    else if (displayOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        textureCoordInfo.leftTop.x = s_max;
        textureCoordInfo.leftTop.y = t_max;
        textureCoordInfo.leftBottom.x = s_min;
        textureCoordInfo.leftBottom.y = t_max;
        textureCoordInfo.rightBottom.x = s_min;
        textureCoordInfo.rightBottom.y = t_min;
        textureCoordInfo.rightTop.x = s_max;
        textureCoordInfo.rightTop.y = t_min;
    }
    else if (displayOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        // home button is on the left side
        
        textureCoordInfo.leftTop.x = s_max;
        textureCoordInfo.leftTop.y = t_min;
        textureCoordInfo.leftBottom.x = s_max;
        textureCoordInfo.leftBottom.y = t_max;
        textureCoordInfo.rightBottom.x = s_min;
        textureCoordInfo.rightBottom.y = t_max;
        textureCoordInfo.rightTop.x = s_min;
        textureCoordInfo.rightTop.y = t_min;
    }
    else if (displayOrientation == UIInterfaceOrientationLandscapeRight)
    {
        // home button is on the right side
        
        textureCoordInfo.leftTop.x = s_min;
        textureCoordInfo.leftTop.y = t_max;
        textureCoordInfo.leftBottom.x = s_min;
        textureCoordInfo.leftBottom.y = t_min;
        textureCoordInfo.rightBottom.x = s_max;
        textureCoordInfo.rightBottom.y = t_min;
        textureCoordInfo.rightTop.x = s_max;
        textureCoordInfo.rightTop.y = t_max;
    }
    
    return textureCoordInfo;
}

@end
