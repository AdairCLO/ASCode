//
//  ASCImageVideoView.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/7.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AVAsset;

@interface ASCImageVideoView : UIView

@property (nullable, nonatomic, strong) UIImage *image;

@property (nullable, nonatomic, strong) NSURL *videoURL;
@property (nullable, nonatomic, strong) AVAsset *videoAsset;

- (void)play;
- (void)pause;
- (void)stop;

- (void)setVideoPlaybackImage:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
