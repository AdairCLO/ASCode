//
//  ASCWXPickerMediaModel.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/13.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerMediaModel.h"
#import <Photos/Photos.h>

@interface ASCWXPickerMediaModel ()

@property (nonatomic, strong) PHAssetCollection *collection;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assetsFetchResult;
@property (nonatomic, strong) PHImageManager *imageManager;

@end

@implementation ASCWXPickerMediaModel

@synthesize editedImageData = _editedImageData;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // recent album
        PHFetchResult<PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        _collection = fetchResult.firstObject;
        // TODO: when no "use photo library" privacy, _collection will return nil
//        assert(_collection != nil);
        
        [self reloadAssets];
        
        _imageManager = [PHImageManager defaultManager];
    }
    return self;
}

- (NSString *)albumIdentifier
{
    return _collection.localIdentifier;
}

- (void)setAlbumIdentifier:(NSString *)albumIdentifier
{
    if (albumIdentifier.length == 0 || [_collection.localIdentifier isEqualToString:albumIdentifier])
    {
        return;
    }
    
    PHFetchResult<PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[ albumIdentifier ] options:nil];
    _collection = fetchResult.firstObject;
    assert(_collection != nil);
    
    [self reloadAssets];
}

- (NSString *)albumTitle
{
    return self.collection.localizedTitle;
}

- (NSUInteger)count
{
    return self.assetsFetchResult.count;
}

- (NSString *)identifierWithIndex:(NSUInteger)index
{
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:index];
    return asset.localIdentifier;
}

- (NSUInteger)indexWithIdentifier:(NSString *)identifier
{
    __block NSUInteger result = NSNotFound;
    if (identifier.length > 0)
    {
        [self.assetsFetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localIdentifier isEqualToString:identifier])
            {
                result = idx;
                *stop = YES;
            }
        }];
    }
    return result;
}

- (BOOL)isVideoWithIndex:(NSUInteger)index
{
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:index];
    return (asset.mediaType == PHAssetMediaTypeVideo);
}

- (BOOL)isEditedWithIndex:(NSUInteger)index
{
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:index];
    return ([self.editedImageData objectForKey:asset.localIdentifier] != nil);
}

- (NSTimeInterval)durationWithIndex:(NSUInteger)index
{
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:index];
    return asset.duration;
}

- (void)requestImageWithIndex:(NSUInteger)index size:(CGSize)size completed:(void(^)(UIImage *image, NSString *mediaIdentifier))completed
{
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:index];
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
    PHAsset *asset = [self.assetsFetchResult objectAtIndex:index];
    if (asset == nil)
    {
        return;
    }
    
    // notice: if size's width or height is 0, will return the original size image!!!!!!
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

- (void)reloadAssets
{
    self.assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:nil];
}

@end
