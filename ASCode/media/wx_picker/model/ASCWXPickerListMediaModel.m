//
//  ASCWXPickerListMediaModel.m
//  ASCode
//
//  Created by Adair Wang on 2020/11/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerListMediaModel.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface ASCWXPickerListMediaModel ()

@property (nonatomic, strong) NSMutableArray<NSString *> *mediaIdentifiers;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assetsFetchResult;
@property (nonatomic, strong) PHImageManager *imageManager;

@end

@implementation ASCWXPickerListMediaModel

@synthesize editedImageData = _editedImageData;

- (instancetype)initWithMediaIdentifers:(NSArray<NSString *> *)mediaIdentifiers
{
    self = [super init];
    if (self)
    {
        _mediaIdentifiers = [mediaIdentifiers mutableCopy];
        _assetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:mediaIdentifiers options:nil];
        assert(_mediaIdentifiers.count == _assetsFetchResult.count);
        _imageManager = [PHImageManager defaultManager];
    }
    return self;
}

- (void)addWithMediaIdentifier:(NSString *)mediaIdentifier
{
    if (mediaIdentifier.length == 0)
    {
        return;
    }
    
    [self.mediaIdentifiers addObject:mediaIdentifier];
    // update fetchResult
    self.assetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:self.mediaIdentifiers options:nil];
}

- (void)removeWithMediaIdentifier:(NSString *)mediaIdentifier
{
    if (mediaIdentifier.length == 0)
    {
        return;
    }
    
    [self.mediaIdentifiers removeObject:mediaIdentifier];
    // update fetchResult
    self.assetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:self.mediaIdentifiers options:nil];
}

- (NSUInteger)resultIndexFromOriginalIndex:(NSUInteger)index
{
    __block NSUInteger resultIndex = 0;
    NSString *identifier = [self.mediaIdentifiers objectAtIndex:index];
    [self.assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([identifier isEqualToString:obj.localIdentifier])
        {
            resultIndex = idx;
            *stop = YES;
        }
    }];
    return resultIndex;
}

- (NSUInteger)count
{
    return self.assetsFetchResult.count;
}

- (NSString *)identifierWithIndex:(NSUInteger)index
{
    NSUInteger resultIndex = [self resultIndexFromOriginalIndex:index];
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:resultIndex];
    return asset.localIdentifier;
}

- (NSUInteger)indexWithIdentifier:(NSString *)identifier
{
    return [self.mediaIdentifiers indexOfObject:identifier];
}

- (BOOL)isVideoWithIndex:(NSUInteger)index
{
    NSUInteger resultIndex = [self resultIndexFromOriginalIndex:index];
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:resultIndex];
    return (asset.mediaType == PHAssetMediaTypeVideo);
}

- (BOOL)isEditedWithIndex:(NSUInteger)index
{
    NSUInteger resultIndex = [self resultIndexFromOriginalIndex:index];
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:resultIndex];
    return ([self.editedImageData objectForKey:asset.localIdentifier] != nil);
}

- (NSTimeInterval)durationWithIndex:(NSUInteger)index
{
    NSUInteger resultIndex = [self resultIndexFromOriginalIndex:index];
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:resultIndex];
    return asset.duration;
}

- (void)requestImageWithIndex:(NSUInteger)index size:(CGSize)size completed:(void(^)(UIImage *image, NSString *mediaIdentifier))completed
{
    NSUInteger resultIndex = [self resultIndexFromOriginalIndex:index];
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:resultIndex];
    if (asset == nil)
    {
        return;
    }
    
    UIImage *editedImage = [self.editedImageData objectForKey:asset.localIdentifier];
    if (editedImage != nil)
    {
        if (completed != nil)
        {
            completed(editedImage, asset.localIdentifier);
        }
        return;
    }
    
    [self.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        assert([NSThread isMainThread]);
        if (completed != nil)
        {
            completed(result, asset.localIdentifier);
        }
    }];
}

- (void)requestVideoWithIndex:(NSUInteger)index completed:(void(^)(AVAsset *videoAsset, NSString *mediaIdentifier))completed
{
    NSUInteger resultIndex = [self resultIndexFromOriginalIndex:index];
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:resultIndex];
    if (asset == nil)
    {
        return;
    }
    
    [self.imageManager requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable result, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        assert(![NSThread isMainThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed != nil)
            {
                completed(result, asset.localIdentifier);
            }
        });
    }];
}

@end
