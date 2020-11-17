//
//  ASCVideoView.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/7.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCVideoView.h"
#import <AVFoundation/AVFoundation.h>

static void *kKVOPlayerStatusContext = &kKVOPlayerStatusContext;

@interface ASCVideoView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, assign) BOOL playWhenReady;
@property (nonatomic, strong) UIImageView *playbackImageView;
@property (nonatomic, assign) NSTimeInterval touchBeginTime;

@end

@implementation ASCVideoView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        _playbackImageView = [[UIImageView alloc] init];
        _playbackImageView.contentMode = UIViewContentModeScaleAspectFit;
        _playbackImageView.image = [[self class] defaultPlaybackImage];
        [self addSubview:_playbackImageView];
        
        _loopEnabled = NO;
        _tapToTogglePlaybackStatusEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_player != nil)
    {
        [_player removeObserver:self forKeyPath:@"status" context:kKVOPlayerStatusContext];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize imgSize = self.playbackImageView.image.size;
    self.playbackImageView.frame = CGRectMake((self.frame.size.width - imgSize.width) / 2,
                                              (self.frame.size.height - imgSize.height) / 2,
                                              imgSize.width,
                                              imgSize.height);
}

- (void)onTap
{
    [self togglePlaybackStatus];
}

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    AVPlayerItem *playerItem = nil;
    if (videoURL != nil)
    {
        playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
    }
    self.playerItem = playerItem;
    [self updatePlayer];
    
    self.playWhenReady = NO;
    self.playbackImageView.hidden = NO;
}

- (void)setVideoAsset:(AVAsset *)videoAsset
{
    _videoAsset = videoAsset;
    
    AVPlayerItem *playerItem = nil;
    if (videoAsset != nil)
    {
        playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
    }
    self.playerItem = playerItem;
    [self updatePlayer];
    
    self.playWhenReady = NO;
    self.playbackImageView.hidden = NO;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem)
    {
        return;
    }
    
    if (_playerItem != nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
    if (playerItem != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayToEndNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    }
    _playerItem = playerItem;
}

- (void)updatePlayer
{
    if (_player == nil)
    {
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kKVOPlayerStatusContext];
        ((AVPlayerLayer *)self.layer).player = _player;
    }
    else
    {
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

- (void)play
{
    if (_playerItem == nil)
    {
        return;
    }
    
    // "call player's play method only when player's status is ready to play"... is this logic necessary??(to detect error??)
    if (self.player.status == AVPlayerStatusReadyToPlay)
    {
        [self.player play];
        
        self.playWhenReady = NO;
    }
    else
    {
        self.playWhenReady = YES;
    }
    self.playbackImageView.hidden = YES;
}

- (void)pause
{
    if (_playerItem == nil)
    {
        return;
    }
    
    [self.player pause];
    
    self.playWhenReady = NO;
    self.playbackImageView.hidden = NO;
}

- (void)stop
{
    if (_playerItem == nil)
    {
        return;
    }
    
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    
    self.playWhenReady = NO;
    self.playbackImageView.hidden = NO;
}

- (void)togglePlaybackStatus
{
    if (_playerItem == nil)
    {
        return;
    }
    
    if (self.playbackImageView.hidden)
    {
        [self pause];
    }
    else
    {
        [self play];
    }
}

- (void)setPlaybackImage:(UIImage *)img
{
    self.playbackImageView.image = img;
}

+ (UIImage *)defaultPlaybackImage
{
    CGSize size = CGSizeMake(80, 80);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineWidth = 4;
    [bezierPath moveToPoint:CGPointMake(30, 24)];
    [bezierPath addLineToPoint:CGPointMake(58, 40)];
    [bezierPath addLineToPoint:CGPointMake(30, 56)];
    [bezierPath addLineToPoint:CGPointMake(30, 24)];
    [bezierPath stroke];
    [bezierPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - notification

- (void)onPlayToEndNotification:(NSNotification *)notification
{
    [self.player seekToTime:kCMTimeZero];
    if (self.loopEnabled)
    {
        [self play];
    }
    else
    {
        self.playbackImageView.hidden = NO;
    }
}

#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == kKVOPlayerStatusContext)
    {
        if (self.player.status == AVPlayerStatusReadyToPlay && self.playWhenReady)
        {
            [self.player play];
            
            self.playWhenReady = NO;
        }
    }
}

@end
