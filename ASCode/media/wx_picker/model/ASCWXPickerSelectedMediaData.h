//
//  ASCWXPickerSelectedMediaData.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/16.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASCWXPickerResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASCWXPickerSelectedMediaData : NSObject

@property (nonatomic, assign) NSUInteger maxSelection;
@property (nonatomic, strong) NSDictionary<NSString *, UIImage *> *editedImageData;

- (NSArray<NSString *> *)selectedMediaIdentifiers;

// 0 based index; -1 if not found
- (NSInteger)indexOfMediaWithIdentifier:(NSString *)mediaIdentifier;
- (void)selectMediaWithIdentifier:(NSString *)mediaIdentifier;
- (void)selectMediaWithIdentifier:(NSString *)mediaIdentifier atIndex:(NSUInteger)index;
- (void)deselectMediaWithIdentifier:(NSString *)mediaIdentifier;
- (NSUInteger)count;
- (BOOL)canSelectMore;

- (void)requestAllSelectedMediaWithCompleted:(void(^)(NSArray<ASCWXPickerResult *> *results))completed;

@end

NS_ASSUME_NONNULL_END
