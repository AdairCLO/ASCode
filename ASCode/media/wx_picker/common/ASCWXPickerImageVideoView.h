//
//  ASCWXPickerImageVideoView.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/2.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AVAsset;
@class ASCWXPickerImageVideoView;

@protocol ASCWXPickerImageVideoViewDelegate <NSObject>

- (void)imageVideoViewVideoPlaybackButtonDidClick:(ASCWXPickerImageVideoView *)imageVideoView;
- (void)imageVideoViewVideoDidPlayToEnd:(ASCWXPickerImageVideoView *)imageVideoView;

@end

@interface ASCWXPickerImageVideoView : UIView

@property (nullable, nonatomic, strong) UIImage *image;

@property (nullable, nonatomic, strong) NSURL *videoURL;
@property (nullable, nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, assign, readonly) BOOL isVideoPlaying;
@property (nonatomic, weak) id<ASCWXPickerImageVideoViewDelegate> delegate;

- (void)play;
- (void)pause;
- (void)stop;

- (void)setVideoPlaybackImage:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
