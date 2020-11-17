//
//  ASCWXPickerLoadingViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/17.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerLoadingViewController.h"

static const CGFloat kContentViewSize = 60;

@interface ASCWXPickerLoadingViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation ASCWXPickerLoadingViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.3];
    [self.view addSubview:_backgroundView];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - kContentViewSize) / 2, (self.view.frame.size.height - kContentViewSize) / 2, kContentViewSize, kContentViewSize)];
    _contentView.layer.cornerRadius = 4;
    _contentView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:_contentView];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.frame = CGRectMake((_contentView.frame.size.width - _indicatorView.frame.size.width) / 2, (_contentView.frame.size.height - _indicatorView.frame.size.height) / 2, _indicatorView.frame.size.width, _indicatorView.frame.size.height);
    [_contentView addSubview:_indicatorView];
    [_indicatorView startAnimating];
}

@end
