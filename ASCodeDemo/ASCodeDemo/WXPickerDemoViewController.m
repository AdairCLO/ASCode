//
//  WXPickerDemoViewController.m
//  ASCodeDemo
//
//  Created by Adair Wang on 2020/11/7.
//

#import "WXPickerDemoViewController.h"
#import <ASCode/ASCode.h>
#import <PhotosUI/PhotosUI.h>

@interface WXPickerDemoViewController () <UITableViewDataSource, UITableViewDelegate, ASCWXPickerViewControllerDelegate, ASCWXPickerCaptureViewControllerDelegate>//, PHPickerViewControllerDelegate>

@property (nonatomic, strong) NSArray<NSDictionary *> *configs;

@property (nonatomic, strong) ASCImageVideoView *imageVideoView;

@end

@implementation WXPickerDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"WXPicker Demo";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.configs = @[
        @{
            @"title": @"Test WXPicker",
            @"vcBlock": ^{
                ASCWXPickerViewController *vc = [[ASCWXPickerViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.delegate = self;
                return vc;
            }
        },
        @{
            @"title": @"Test WXCapture",
            @"vcBlock": ^{
                ASCWXPickerCaptureViewController *vc = [[ASCWXPickerCaptureViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.delegate = self;
                return vc;
            }
        },
        @{
            @"title": @"Test UIImagePicker",
            @"vcBlock": ^{
                UIImagePickerController *vc = [[UIImagePickerController alloc] init];
//                PHPickerConfiguration *pickerConfig = [[PHPickerConfiguration alloc] init];
//                PHPickerViewController *vc = [[PHPickerViewController alloc] initWithConfiguration:pickerConfig];
//                vc.delegate = self;
                return vc;
            }
        },
    ];
    
    CGFloat imageViewHeight = self.view.frame.size.height / 2;
    _imageVideoView = [[ASCImageVideoView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - imageViewHeight, self.view.frame.size.width, imageViewHeight)];
    _imageVideoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_imageVideoView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - imageViewHeight) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableView];
}

- (void)onButtonClick:(UIButton *)b
{
    NSDictionary *config = [self.configs objectAtIndex:b.tag];
    UIViewController *(^vcBlock)(void) = [config objectForKey:@"vcBlock"];
    UIViewController *vc = vcBlock();
    
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.configs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *config = [self.configs objectAtIndex:indexPath.row];
    UIButton *b = nil;
    if (cell.contentView.subviews.count == 0)
    {
        b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(0, 0, self.view.bounds.size.width, cell.bounds.size.height);
        [b addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:b];
    }
    else
    {
        b = cell.contentView.subviews.firstObject;
    }
    b.tag = indexPath.row;
    
    NSString *title = [config objectForKey:@"title"];
    [b setTitle:title forState:UIControlStateNormal];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - ASCWXPickerViewControllerDelegate

- (void)ascWXPicer:(ASCWXPickerViewController *)picker didFinishPicking:(NSArray<ASCWXPickerResult *> *)results
{
    NSLog(@"picker did finish: %@", results.count > 0 ? @(results.count) : @"CANCEL!!");
    [results enumerateObjectsUsingBlock:^(ASCWXPickerResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%zd - %@", idx + 1, obj.videoAsset != nil ? @"视频" : @"图片");
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (results.firstObject.videoAsset != nil)
    {
        self.imageVideoView.videoAsset = results.firstObject.videoAsset;
    }
    else
    {
        self.imageVideoView.image = results.firstObject.image;
    }
}

#pragma mark - ASCWXPickerCaptureViewControllerDelegate

- (void)ascWXPicerCaptureVC:(ASCWXPickerCaptureViewController *)captureVC didFinishCapturing:(ASCWXPickerCaptureResult *)result
{
    NSLog(@"capture did finish: %@ - %@; %@", result != nil ? [NSString stringWithFormat:@"CAPTURE %@", result.videoURL != nil ? @"视频" : @"图片"] : @"CANCEL!!", result.image, result.videoURL);
    [captureVC dismissViewControllerAnimated:YES completion:nil];
    
    if (result.videoURL != nil)
    {
        self.imageVideoView.videoURL = result.videoURL;
    }
    else
    {
        self.imageVideoView.image = result.image;
    }
}

#pragma mark - PHPickerViewControllerDelegate

//- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
//{
//    NSLog(@"%@", results);
//
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

@end
