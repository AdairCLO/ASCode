//
//  ASCWXPickerAlertViewController.m
//  ASCode
//
//  Created by Adair Wang on 2020/10/20.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASCWXPickerAlertViewController.h"
#import "ASCWXPickerUtility.h"

static const CGFloat kContentViewWidth = 300;
static const CGFloat kContentViewHeight = 160;
static const CGFloat kContentViewButtonHeight = 55;
static const CGFloat kContentViewTitleHeight = 160 - kContentViewButtonHeight;
static const CGFloat kSeparatorViewTitleHeight = 0.5;

@interface ASCWXPickerAlertViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *okButton;

@end

@implementation ASCWXPickerAlertViewController

- (instancetype)init
{
    return [self initWithTitle:@""];
}

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:_backgroundView];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - kContentViewWidth) / 2, (self.view.frame.size.height - kContentViewHeight) / 2, kContentViewWidth, kContentViewHeight)];
    _contentView.layer.cornerRadius = 8;
    _contentView.clipsToBounds = YES;
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = self.title;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:20];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake((_contentView.frame.size.width - _titleLabel.frame.size.width) / 2,
                                   (kContentViewTitleHeight - _titleLabel.frame.size.height) / 2,
                                   _titleLabel.frame.size.width,
                                   _titleLabel.frame.size.height);
    [_contentView addSubview:_titleLabel];
    
    _okButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kContentViewTitleHeight, _contentView.frame.size.width, kContentViewButtonHeight)];
    _okButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_okButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor colorWithRed:86/255.0 green:107/255.0 blue:148/255.0 alpha:1] forState:UIControlStateNormal];
    [_okButton addTarget:self action:@selector(onOKClicked) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setBackgroundImage:[ASCWXPickerUtility imageWithColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]] forState:UIControlStateHighlighted];
    [_contentView addSubview:_okButton];
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, kContentViewTitleHeight, _contentView.frame.size.width, kSeparatorViewTitleHeight)];
    _separatorView.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1];
    [_contentView addSubview:_separatorView];
}

- (void)onOKClicked
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
