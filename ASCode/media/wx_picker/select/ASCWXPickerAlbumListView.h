//
//  ASCWXPickerAlbumListView.h
//  ASCode
//
//  Created by Adair Wang on 2020/10/13.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ASCWXPickerAlbumListView;

@protocol ASCWXPickerAlbumListViewDelegate <NSObject>

@optional

- (void)pickerAlbumListView:(ASCWXPickerAlbumListView *)view didSelectAlbumWithIdentifier:(NSString *)identifier title:(NSString *)title;
- (void)pickerAlbumListViewDidCancel:(ASCWXPickerAlbumListView *)view;

@end

@interface ASCWXPickerAlbumListView : UIView

@property (nonatomic, weak) id<ASCWXPickerAlbumListViewDelegate> delegate;

- (void)showView;
- (void)hideView;

@end

NS_ASSUME_NONNULL_END
