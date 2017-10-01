//
//  DMAlbumViewController.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//


#import "DMAlbumViewController.h"
#import "DMDefine.h"
#import "DMPhotoManager.h"
#import "DMAlbumCell.h"
#import "DMThumbnailController.h"
#import "DMProgressView.h"
#import "DMImagePickerController.h"

@interface DMAlbumViewController ()<UITableViewDelegate,UITableViewDataSource, PHPhotoLibraryChangeObserver> {

    NSString *_selectedAlbumId;
}

@property (nonatomic, strong)NSArray<DMAlbumModel *> *arrAlbumModel;

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation DMAlbumViewController

- (NSArray<DMAlbumModel *> *)arrAlbumModel {
    
    if (!_arrAlbumModel) {
        
        _arrAlbumModel = [NSArray array];

    }
    
    return _arrAlbumModel;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    [self initNavigationBar];
    [self fetchData];
    
    //相册本地+iCloud监听
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {

    NSLog(@"%s", __func__);
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark 请求相册列表数据
- (void)fetchData {
    
    DMProgressView *progressView = [DMProgressView showLoadingViewAddTo:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[DMPhotoManager shareManager] getAllAlbumsCompletion:^(NSArray<DMAlbumModel *> *arrAblum) {
            
            self.arrAlbumModel = [NSArray arrayWithArray:arrAblum];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                [progressView hideLoadingView];
            });
            
        }];
    });
}

#pragma mark 初始化tableView
- (void)initTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, KScreen_Height)];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - 初始化导航栏
- (void)initNavigationBar {
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AlbumPhotoImageViewBottomBK123"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    cancelBtn.frame = CGRectMake(5, 0, 48, 30);
    [cancelBtn addTarget:self action:@selector(didClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
    [view addSubview:cancelBtn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrAlbumModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reusedId = @"album";
    
    DMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    
    if (!cell) {
        
        cell = [[DMAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    
    DMAlbumModel *albumModel = self.arrAlbumModel[indexPath.row];
    
    cell.albumModel = albumModel;
    
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return KAlbumViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DMAlbumCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    DMAlbumModel *albumModel = self.arrAlbumModel[indexPath.row];
    
    DMThumbnailController *thumbnailsController = [[DMThumbnailController alloc] init];
    thumbnailsController.albumModel = albumModel;
    thumbnailsController.isFromTapAlbum = YES;
    
    [self.navigationController pushViewController:thumbnailsController animated:YES];
        
}

#pragma mark 导航栏取消按钮
- (void)didClickCancelButton {
    
    DMImagePickerController *imagePickerController = (DMImagePickerController *)self.navigationController;
    
    if (imagePickerController.didCancelPickingImageWithHandle) {
        
        imagePickerController.didCancelPickingImageWithHandle();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - 相册本地+iCloud监听
- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
       [self fetchData];
    });
}

@end
