//
//  ASCWXPickerTextEditViewController.m
//  ASCode
//
//  Created by Adair Wang on 2021/4/28.
//  Copyright © 2021 Adair Studio. All rights reserved.
//

#import "ASCWXPickerTextEditViewController.h"
#import "ASCWXPickerTopBarView.h"
#import "ASCWXPickerColorResource.h"
#import "ASCWXPickerTextEditOperationView.h"

static const CGFloat kTextViewMargin = 10;
static const CGFloat kTextViewPadding = 8;
static const CGFloat kTextViewCornerRadius = 8;
static const NSUInteger kTextViewMaxCharCount = 100;

@interface ASCWXPickerTextEditViewController () <UITextViewDelegate>

@property (nonatomic, strong) ASCWXPickerTopBarView *topBarView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) ASCWXPickerTextEditOperationView *operationView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) CGSize maxTextViewSize;

@end

@implementation ASCWXPickerTextEditViewController

- (instancetype)init
{
    return [self initWithLabel:nil];
}

- (instancetype)initWithLabel:(nullable UILabel *)label
{
    self = [super init];
    if (self)
    {
        _label = label;
        if (_label == nil)
        {
            _label = [[UILabel alloc] init];
            _label.textColor = [UIColor whiteColor];
            _label.backgroundColor = [UIColor clearColor];
            _label.font = [[self class] textFont];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIKeyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
    backgroundView.frame = self.view.bounds;
    [self.view addSubview:backgroundView];
    
    // top bar
    _topBarView = [[ASCWXPickerTopBarView alloc] init];
    _topBarView.translucent = NO;
    [self.view addSubview:_topBarView];
    // top bar - left
    UIButton *topBarViewLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [topBarViewLeftButton setTitle:@"取消" forState:UIControlStateNormal];
    topBarViewLeftButton.titleLabel.font = [UIFont systemFontOfSize:17];
    topBarViewLeftButton.tintColor = [UIColor whiteColor];
    [topBarViewLeftButton sizeToFit];
    [topBarViewLeftButton addTarget:self action:@selector(onCancelClicked) forControlEvents:UIControlEventTouchUpInside];
    _topBarView.leftView = topBarViewLeftButton;
    UIButton *topBarViewRightButton = [[UIButton alloc] init];
    topBarViewRightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [topBarViewRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [topBarViewRightButton setTitle:@"完成" forState:UIControlStateNormal];
    [topBarViewRightButton addTarget:self action:@selector(onDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    topBarViewRightButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    topBarViewRightButton.layer.cornerRadius = 3;
    topBarViewRightButton.backgroundColor = [ASCWXPickerColorResource themeColor];
    [topBarViewRightButton sizeToFit];
    _topBarView.rightView = topBarViewRightButton;
    
    // operation view
    __weak typeof(self) weakSelf = self;
    _operationView = [[ASCWXPickerTextEditOperationView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    _operationView.colorChangedHandler = ^(ASCWXPickerTextEditOperationView * _Nonnull view) {
        if (view.isBackgroundColorMode)
        {
            weakSelf.textView.backgroundColor = view.currentColor;
            weakSelf.textView.textColor = [UIColor whiteColor];
        }
        else
        {
            weakSelf.textView.backgroundColor = [UIColor clearColor];
            weakSelf.textView.textColor = view.currentColor;
        }
    };
    _operationView.colorModeChangedHandler = ^(ASCWXPickerTextEditOperationView * _Nonnull view) {
        if (view.isBackgroundColorMode)
        {
            weakSelf.textView.backgroundColor = view.currentColor;
            weakSelf.textView.textColor = [UIColor whiteColor];
            [weakSelf updateTextViewSize];
        }
        else
        {
            weakSelf.textView.backgroundColor = [UIColor clearColor];
            weakSelf.textView.textColor = view.currentColor;
        }
    };
    BOOL isBackgroundColorMode = (_label.backgroundColor != [UIColor clearColor]);
    UIColor *color = (isBackgroundColorMode ? _label.backgroundColor : _label.textColor);
    [_operationView updateColor:color isBackgroundColorMode:isBackgroundColorMode];
    [self.view addSubview:_operationView];
    
    _maxTextViewSize = CGSizeMake(self.view.frame.size.width - kTextViewMargin - kTextViewMargin, 300);
    
    // text view
    _textView = [[UITextView alloc] init];
    _textView.delegate = self;
    _textView.textAlignment = NSTextAlignmentLeft;
    _textView.font = [[self class] textFont];
    _textView.textContainerInset = UIEdgeInsetsMake(kTextViewPadding, kTextViewPadding, kTextViewPadding, kTextViewPadding);
    _textView.textContainer.lineFragmentPadding = 0;
    _textView.textColor = (_operationView.isBackgroundColorMode ? [UIColor whiteColor] : _operationView.currentColor);
    _textView.backgroundColor = (_operationView.isBackgroundColorMode ? _operationView.currentColor : [UIColor clearColor]);
    _textView.layer.cornerRadius = kTextViewCornerRadius;
    _textView.text = _label.text;
    [self updateTextViewSize];
    [self.view addSubview:_textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_textView becomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)onCancelClicked
{
    if (self.completeHandler != nil)
    {
        self.completeHandler(self, YES);
    }
    
    [self closeVC];
}

- (void)onDoneClicked
{
    [self completeEditText];
}

- (void)updateLabel
{
    // TODO: [edit] 1) backgroundColor with cornerRadius, support "full line + partial line"; 2) label's padding
    
    self.label.text = self.textView.text;
    self.label.textColor = self.textView.textColor;
    self.label.backgroundColor = self.textView.backgroundColor;
    CGPoint center = self.label.center;
    self.label.frame = CGRectMake(self.label.frame.origin.x, self.label.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
    self.label.center = center;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.layer.cornerRadius = self.textView.layer.cornerRadius;
    self.label.layer.masksToBounds = YES;
    self.label.numberOfLines = 0;
}

- (void)updateTextViewSize
{
    CGSize size = [_textView sizeThatFits:_maxTextViewSize];
    _textView.frame = CGRectMake(kTextViewMargin, CGRectGetMaxY(_topBarView.frame), size.width, size.height);
    if (_operationView.isBackgroundColorMode)
    {
        _textView.backgroundColor = (_textView.text.length == 0 ? [UIColor clearColor] : _operationView.currentColor);
    }
}

- (void)completeEditText
{
    [self updateLabel];
    
    if (self.completeHandler != nil)
    {
        self.completeHandler(self, NO);
    }
    
    [self closeVC];
}

- (void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (UIFont *)textFont
{
    return [UIFont systemFontOfSize:28];
}

#pragma mark -- notification

- (void)onUIKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    NSTimeInterval animationTime = [((NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]) floatValue];
    UIViewAnimationOptions animationOptions = [((NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]) unsignedIntegerValue];
    CGRect keyboardFrameEnd = [((NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]) CGRectValue];
    
    [UIView animateWithDuration:animationTime delay:0 options:animationOptions animations:^{
        self.operationView.frame = CGRectMake(self.operationView.frame.origin.x, CGRectGetMinY(keyboardFrameEnd) - self.operationView.frame.size.height, self.operationView.frame.size.width, self.operationView.frame.size.height);
    } completion:nil];
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [self completeEditText];
        return NO;
    }
    
    NSUInteger count = textView.text.length + (text.length - range.length);
    return count <= kTextViewMaxCharCount;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextViewSize];
}

@end
