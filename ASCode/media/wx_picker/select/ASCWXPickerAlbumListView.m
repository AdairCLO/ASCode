//
//  ASCWXPickerAlbumListView.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/13.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerAlbumListView.h"
#import "ASCWXPickerMediaAlbumModel.h"
#import "ASCWXPickerAlbumCell.h"
#import "ASCWXPickerImageResource.h"
#import "ASCWXPickerColorResource.h"

static const CGFloat kCellHeight = 56;
static const CGFloat kGradientHeight = 40;

@interface ASCWXPickerAlbumListView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CGRect targetFrame;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) ASCWXPickerMediaAlbumModel *mediaAlbumModel;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation ASCWXPickerAlbumListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.hidden = YES;
        self.clipsToBounds = YES;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgourndClicked)];
        [_backgroundView addGestureRecognizer:tap];
        [self addSubview:_backgroundView];
        
        CGFloat tableViewHeight = MIN(frame.size.height - 20, kCellHeight * 10 + 10);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, tableViewHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [ASCWXPickerColorResource backgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ASCWXPickerAlbumCell class] forCellReuseIdentifier:@"cell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
        self.targetFrame = self.tableView.frame;
        
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = CGRectMake(0, tableViewHeight - kGradientHeight, _tableView.frame.size.width, kGradientHeight);
        _gradientLayer.colors = @[ (id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor ];
        [self.layer addSublayer:_gradientLayer];
        
        _mediaAlbumModel = [[ASCWXPickerMediaAlbumModel alloc] init];
    }
    return self;
}

- (void)onBackgourndClicked
{
    [self.delegate pickerAlbumListViewDidCancel:self];
}

#pragma mark - animation

- (void)showView
{
    [self checkSelected];
    
    self.hidden = NO;
    self.alpha = 0;
    self.tableView.frame = [self sourceFrame];
    self.gradientLayer.opacity = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
        self.tableView.frame = self.targetFrame;
        self.gradientLayer.opacity = 1;
        } completion:^(BOOL finished) {
            
        }];
}

- (void)hideView
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
        self.tableView.frame = [self sourceFrame];
        self.gradientLayer.opacity = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
}

- (CGRect)sourceFrame
{
    return CGRectMake(self.targetFrame.origin.x,
                      self.targetFrame.origin.y - self.targetFrame.size.height,
                      self.targetFrame.size.width,
                      self.targetFrame.size.height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaAlbumModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASCWXPickerAlbumCell *cell = (ASCWXPickerAlbumCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.tintColor = [ASCWXPickerColorResource themeColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *title = [self.mediaAlbumModel titleWithIndex:indexPath.row];
    NSUInteger count = [self.mediaAlbumModel photoCountWithIndex:indexPath.row];
    NSString *goodTitleString = [NSString stringWithFormat:@"%@ (%zd)", title, count];
    cell.textLabel.textColor = [ASCWXPickerColorResource mainTextColor];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:goodTitleString];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[ASCWXPickerColorResource subTextColor] range:NSMakeRange(title.length + 1, goodTitleString.length - title.length - 1)];
    cell.textLabel.attributedText = attributedText;
    
    NSString *cellAlbumIdentifier = [self.mediaAlbumModel identifierWithIndex:indexPath.row];
    cell.albumIdentifier = cellAlbumIdentifier;
    cell.imageView.image = [ASCWXPickerImageResource defaultMediaImage];
    [self.mediaAlbumModel requestImageWithIndex:indexPath.row completed:^(UIImage * _Nonnull image, NSString * _Nonnull albumIdentifier) {
        if ([albumIdentifier isEqualToString:cellAlbumIdentifier] && image != nil)
        {
            cell.imageView.image = image;
        }
    }];
    
    cell.accessoryType = (indexPath.row == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    
//    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
//        cell.accessoryType = (cellIndexPath.row == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    }];
    
    NSString *selectedIdentifier = [self.mediaAlbumModel identifierWithIndex:self.selectedIndex];
    NSString *selectedTitle = [self.mediaAlbumModel titleWithIndex:self.selectedIndex];
    [self.delegate pickerAlbumListView:self didSelectAlbumWithIdentifier:selectedIdentifier title:selectedTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

#pragma mark - private

- (void)checkSelected
{
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        cell.accessoryType = (cellIndexPath.row == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }];
}

@end
