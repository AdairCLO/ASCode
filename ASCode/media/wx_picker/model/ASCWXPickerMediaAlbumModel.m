//
//  ASCWXPickerMediaAlbumModel.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/13.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerMediaAlbumModel.h"
#import <Photos/Photos.h>

static const CGFloat kImageSize = 60;

@interface ASCWXPickerMediaAlbumModel ()

@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *recentAlbumFetchResult;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *smartAlbumsFetchResult;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *userAlbumsFetchResult;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PHFetchResult<PHAsset *> *> *assetFetchResultDict;
@property (nonatomic, strong) PHImageManager *imageManager;

@end

@implementation ASCWXPickerMediaAlbumModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // recent album
        _recentAlbumFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        // smart albums excluding "recent" and "hidden"
        PHFetchOptions *smartAlbumsFetchOptions = nil;
        NSArray<NSString *> *excludeLocalIdentifiers = [self excludeLocalIdentifiersWithCollectionSubtypes:@[ @(PHAssetCollectionSubtypeSmartAlbumUserLibrary), @(PHAssetCollectionSubtypeSmartAlbumAllHidden) ]];
        if (excludeLocalIdentifiers.count > 0)
        {
            smartAlbumsFetchOptions = [[PHFetchOptions alloc] init];
            NSString *predicateFormatString = [self predicateFormatStringWithExcludeLocalIdentifiers:excludeLocalIdentifiers];
            smartAlbumsFetchOptions.predicate = [NSPredicate predicateWithFormat:predicateFormatString];
        }
        _smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:smartAlbumsFetchOptions];
        // user albums
        _userAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        
        _assetFetchResultDict = [[NSMutableDictionary alloc] init];
        
        _imageManager = [PHImageManager defaultManager];
    }
    return self;
}

- (NSUInteger)count
{
    return self.recentAlbumFetchResult.count + self.smartAlbumsFetchResult.count + self.userAlbumsFetchResult.count;
}

- (NSString *)titleWithIndex:(NSUInteger)index
{
    PHAssetCollection *collection = [self collectionWithIndex:index];
    return collection.localizedTitle;
}

- (NSUInteger)photoCountWithIndex:(NSUInteger)index
{
    PHAssetCollection *collection = [self collectionWithIndex:index];
    NSUInteger photoCount = collection.estimatedAssetCount;
    if (photoCount == NSNotFound)
    {
        PHFetchResult *r = [self assetFetchResultForCollection:collection];
        photoCount = r.count;
    }
    return photoCount;
}

- (NSString *)identifierWithIndex:(NSUInteger)index
{
    PHAssetCollection *collection = [self collectionWithIndex:index];
    return collection.localIdentifier;
}

- (void)requestImageWithIndex:(NSUInteger)index completed:(void(^)(UIImage *image, NSString *albumIdentifier))completed
{
    PHAssetCollection *collection = [self collectionWithIndex:index];
    PHAsset *asset = [self assetForCollection:collection];
    if (asset == nil)
    {
        return;
    }
    
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(kImageSize, kImageSize) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completed != nil)
        {
            completed(result, collection.localIdentifier);
        }
    }];
}

#pragma mark - private

- (PHAssetCollection *)collectionWithIndex:(NSUInteger)index
{
    NSUInteger validIndex = index;
    
    if (validIndex < self.recentAlbumFetchResult.count)
    {
        return [self.recentAlbumFetchResult objectAtIndex:validIndex];
    }
    
    validIndex -= self.recentAlbumFetchResult.count;
    
    if (validIndex < self.smartAlbumsFetchResult.count)
    {
        return [self.smartAlbumsFetchResult objectAtIndex:validIndex];
    }
    
    validIndex -= self.smartAlbumsFetchResult.count;
    
    if (validIndex < self.userAlbumsFetchResult.count)
    {
        return [self.userAlbumsFetchResult objectAtIndex:validIndex];
    }
    
    return nil;
}

- (NSArray<NSString *> *)excludeLocalIdentifiersWithCollectionSubtypes:(NSArray<NSNumber *> *)subtypes
{
    NSMutableArray<NSString *> *localIdentifers = [[NSMutableArray alloc] init];
    
    [subtypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult<PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:[obj integerValue] options:nil];
        PHAssetCollection *collection = fetchResult.firstObject;
        if (collection != nil)
        {
            [localIdentifers addObject:collection.localIdentifier];
        }
    }];
    
    return localIdentifers;
}

- (NSString *)predicateFormatStringWithExcludeLocalIdentifiers:(NSArray<NSString *> *)excludeLocalIdentifiers
{
    NSMutableString *formatString = [[NSMutableString alloc] init];
    
    NSUInteger count = excludeLocalIdentifiers.count;
    NSUInteger current = 0;
    while (current < count)
    {
        NSString *localIdentifier = [excludeLocalIdentifiers objectAtIndex:current];
        [formatString appendFormat:@"(localIdentifier != '%@')", localIdentifier];

        current += 1;
        if (current < count)
        {
            [formatString appendString:@" && "];
        }
    }
    
    return formatString;
}

- (PHFetchResult<PHAsset *> *)assetFetchResultForCollection:(PHAssetCollection *)collection
{
    if (collection == nil)
    {
        return nil;
    }
    
    NSString *collectionIdentifier = collection.localIdentifier;
    
    PHFetchResult<PHAsset *> *fetchResult = [self.assetFetchResultDict objectForKey:collectionIdentifier];
    if (fetchResult == nil)
    {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
        option.sortDescriptors = @[ sortDescriptor ];
        fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        [self.assetFetchResultDict setObject:fetchResult forKey:collectionIdentifier];
    }
    
    return fetchResult;
}

- (PHAsset *)assetForCollection:(PHAssetCollection *)collection
{
    PHFetchResult<PHAsset *> *fetchResult = [self assetFetchResultForCollection:collection];
    return fetchResult.firstObject;
}

@end
