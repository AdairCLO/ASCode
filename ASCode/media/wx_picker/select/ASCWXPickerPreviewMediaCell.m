//
//  ASCWXPickerPreviewMediaCell.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerPreviewMediaCell.h"
#import "ASCWXPickerImageResource.h"

@implementation ASCWXPickerPreviewMediaCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageVideoView = [[ASCWXPickerImageVideoView alloc] initWithFrame:self.contentView.bounds];
        [_imageVideoView setVideoPlaybackImage:[ASCWXPickerImageResource playbackImage]];
        [self.contentView addSubview:_imageVideoView];
    }
    return self;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    
    _imageVideoView.frame = CGRectMake(contentInsets.left,
                                       contentInsets.top,
                                       self.contentView.bounds.size.width - contentInsets.left - contentInsets.right,
                                       self.contentView.bounds.size.height - contentInsets.top - contentInsets.bottom);
}

@end
