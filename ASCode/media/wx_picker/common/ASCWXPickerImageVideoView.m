//
//  ASCWXPickerImageVideoView.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/2.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerImageVideoView.h"
#import "ASCWXPickerVideoView.h"

@interface ASCWXPickerImageVideoView () <ASCWXPickerVideoViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ASCWXPickerVideoView *videoView;
@property (nonatomic, strong) UIImage *videoPlaybackImage;

@end

@implementation ASCWXPickerImageVideoView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    _imageView.frame = bounds;
    _videoView.frame = bounds;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
    
    _videoView.videoURL = nil;
    _videoView.videoAsset = nil;
    _videoView.hidden = YES;
}

- (NSURL *)videoURL
{
    return self.videoView.videoURL;
}

- (void)setVideoURL:(NSURL *)videoURL
{
    self.videoView.videoURL = videoURL;
    self.videoView.hidden = NO;
    
    _imageView.image = nil;
    _imageView.hidden = YES;
}

- (AVAsset *)videoAsset
{
    return self.videoView.videoAsset;
}

- (void)setVideoAsset:(AVAsset *)videoAsset
{
    self.videoView.videoAsset = videoAsset;
    self.videoView.hidden = NO;
    
    _imageView.image = nil;
    _imageView.hidden = YES;
}

- (UIImageView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (ASCWXPickerVideoView *)videoView
{
    if (_videoView == nil)
    {
        _videoView = [[ASCWXPickerVideoView alloc] initWithFrame:self.bounds];
        _videoView.delegate = self;
        _videoView.loopEnabled = NO;
        _videoView.tapToTogglePlaybackStatusEnabled = YES;
        if (_videoPlaybackImage != nil)
        {
            [_videoView setPlaybackImage:_videoPlaybackImage];
        }
        [self addSubview:_videoView];
    }
    return _videoView;
}

- (void)play
{
    [_videoView play];
}

- (void)pause
{
    [_videoView pause];
}

- (void)stop
{
    [_videoView stop];
}

- (void)setVideoPlaybackImage:(UIImage *)img
{
    _videoPlaybackImage = img;
    
    if (_videoView != nil)
    {
        [_videoView setPlaybackImage:img];
    }
}

- (BOOL)isVideoPlaying
{
    return _videoView.isPlaying;
}

#pragma mark - ASCWXPickerVideoViewDelegate

- (void)videoViewPlaybackButtonDidClick:(ASCWXPickerVideoView *)videoView
{
    [self.delegate imageVideoViewVideoPlaybackButtonDidClick:self];
}

- (void)videoViewDidPlayToEnd:(ASCWXPickerVideoView *)videoView
{
    [self.delegate imageVideoViewVideoDidPlayToEnd:self];
}

@end
