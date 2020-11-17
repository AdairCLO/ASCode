//
//  ASCVideoView.h
//  ASCode
//
//  Created by Adair Wang on 2020/11/7.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AVAsset;

@interface ASCVideoView : UIView

@property (nullable, nonatomic, strong) NSURL *videoURL;
@property (nullable, nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, assign) BOOL loopEnabled;
@property (nonatomic, assign) BOOL tapToTogglePlaybackStatusEnabled;

- (void)play;
- (void)pause;
- (void)stop;

- (void)setPlaybackImage:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
