//
//  ASCWXPickerSelectedMediaData.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerSelectedMediaData.h"
#import <Photos/Photos.h>

@interface ASCWXPickerSelectedMediaData ()

@property (nonatomic, strong) NSMutableArray<NSString *> *selectedMediaArray;
@property (nonatomic, strong) dispatch_semaphore_t dispatchSemaphore;

@end

@implementation ASCWXPickerSelectedMediaData

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _selectedMediaArray = [[NSMutableArray alloc] initWithCapacity:9];
        _maxSelection = 9;
    }
    return self;
}

- (dispatch_semaphore_t)dispatchSemaphore
{
    if (_dispatchSemaphore == nil)
    {
        _dispatchSemaphore = dispatch_semaphore_create(0);
    }
    return _dispatchSemaphore;
}

- (NSArray<NSString *> *)selectedMediaIdentifiers
{
    return [self.selectedMediaArray copy];
}

- (NSInteger)indexOfMediaWithIdentifier:(NSString *)mediaIdentifier
{
    NSInteger index = [self.selectedMediaArray indexOfObject:mediaIdentifier];
    if (index == NSNotFound)
    {
        return -1;
    }
    return index;
}

- (void)selectMediaWithIdentifier:(NSString *)mediaIdentifier
{
    [self selectMediaWithIdentifier:mediaIdentifier atIndex:self.selectedMediaArray.count];
}

- (void)selectMediaWithIdentifier:(NSString *)mediaIdentifier atIndex:(NSUInteger)index
{
    if (mediaIdentifier.length == 0)
    {
        return;
    }
    
    [self deselectMediaWithIdentifier:mediaIdentifier];
    
    if (self.selectedMediaArray.count >= self.maxSelection)
    {
        return;
    }
    
    assert(index <= _selectedMediaArray.count);
    NSUInteger insertIndex = MIN(index, self.selectedMediaArray.count);
    [self.selectedMediaArray insertObject:mediaIdentifier atIndex:insertIndex];
}

- (void)deselectMediaWithIdentifier:(NSString *)mediaIdentifier
{
    [self.selectedMediaArray removeObject:mediaIdentifier];
}

- (NSUInteger)count
{
    return self.selectedMediaArray.count;
}

- (BOOL)canSelectMore
{
    return self.selectedMediaArray.count < self.maxSelection;
}

- (void)requestAllSelectedMediaWithCompleted:(void(^)(NSArray<ASCWXPickerResult *> *results))completed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<ASCWXPickerResult *> *results = [[NSMutableArray alloc] init];
        
        PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:self.selectedMediaArray options:nil];
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            ASCWXPickerResult *item = [[ASCWXPickerResult alloc] init];
            
            UIImage *editedImage = [self.editedImageData objectForKey:asset.localIdentifier];
            if (editedImage != nil)
            {
                item.image = editedImage;
            }
            else
            {
                PHImageRequestOptions *imageOption = [[PHImageRequestOptions alloc] init];
                imageOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                imageOption.synchronous = YES;
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageOption resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
                    item.image = image;
                }];
            }
            
            if (asset.mediaType == PHAssetMediaTypeVideo)
            {
//                PHVideoRequestOptions *videoOption = [[PHVideoRequestOptions alloc] init];
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    item.videoAsset = avAsset;
                    
                    dispatch_semaphore_signal(self.dispatchSemaphore);
                }];
                
                dispatch_semaphore_wait(self.dispatchSemaphore, DISPATCH_TIME_FOREVER);
            }
            
            [results addObject:item];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed != nil)
            {
                completed(results);
            }
        });
    });
}

@end
