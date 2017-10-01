//
//  ViewController.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "ViewController.h"
#import "DMImagePickerController.h"
#import <Photos/Photos.h>
#import "YYFPSLabel.h"
#import "UIView+layout.h"
#import "DMDefine.h"
#import "DMImageCell.h"
#import "DMPreviewController.h"

static NSString *reusedId = @"showImage";
static CGFloat margin = 10;

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, DMImagePickerDelegate>

@property (nonatomic, strong)NSArray *arrImage;

@property (nonatomic, strong)NSArray *arrAssetModel;

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, assign)BOOL allowRecordSelection;

@end

@implementation ViewController

#pragma mark - lazy load
- (NSArray *)arrImage {

    if (!_arrImage) {
        
        _arrImage = [NSArray array];
    }
    
    return _arrImage;
}

- (NSArray *)arrAssetModel {

    if (!_arrAssetModel) {
        
        _arrAssetModel = [NSArray array];
    }
    
    return _arrAssetModel;
}

- (UICollectionView *)collectionView {

    if (!_collectionView) {
        
        CGFloat itemWH = (KScreen_Width-5*margin)/4;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(itemWH, itemWH);
        flowLayout.minimumLineSpacing = margin;
        flowLayout.minimumInteritemSpacing = margin;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 150, KScreen_Width, KScreen_Height-150) collectionViewLayout:flowLayout];
    }
    
    return _collectionView;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initButton];
    [self initFPS];
    [self initCollectionView];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }];

}

#pragma mark - 初始化
#pragma mark 打开相册按钮
- (void)initButton {

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(openImagePickerVC) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"打开相册" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 100, 100, 30);
    btn.dm_centerX = self.view.center.x;
    [self.view addSubview:btn];
}

#pragma mark FPS
- (void)initFPS {

    YYFPSLabel *labFPS = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, 30, 50, 30)];
    labFPS.dm_centerX = self.view.center.x;
    [labFPS sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:labFPS];
}

#pragma mark collectionView
- (void)initCollectionView {

    [self.collectionView registerClass:[DMImageCell class] forCellWithReuseIdentifier:reusedId];
    self.collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - collection dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.arrImage.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    DMImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedId forIndexPath:indexPath];
    
    cell.image = self.arrImage[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    //根据DMAssetModel进行预览
    DMPreviewController *previewVC = [[DMPreviewController alloc] init];
    previewVC.arrData = self.arrAssetModel;
    previewVC.selectedIndex = indexPath.row;
    
    DMImagePickerController *imagePicker = [[DMImagePickerController alloc] initWithRootViewController:previewVC];
    imagePicker.arrselected = (NSMutableArray *)self.arrAssetModel;
    imagePicker.didFinishPickingImageWithHandle = ^(NSArray<UIImage *> *images, NSArray<NSDictionary *> *infos, NSArray<DMAssetModel *> *assetModels) {
        
        self.arrAssetModel = assetModels;
        self.arrImage = images;
        [self.collectionView reloadData];
    };
    
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark 打开相册
- (void)openImagePickerVC {
    
    DMImagePickerController *imagePickerVC = [[DMImagePickerController alloc] initWithMaxImagesCount:9];
    //记录上一次的选择
    imagePickerVC.allowRecordSelection = self.allowRecordSelection;
    imagePickerVC.allowCrossSelect = YES;
    
    //block
    [imagePickerVC setDidFinishPickingImageWithHandle:^(NSArray<UIImage *> *images, NSArray<NSDictionary *> *infos, NSArray<DMAssetModel *> *assetModels){
       
       for (UIImage *image in images) {
           
           NSLog(@"%f-%f", image.size.width, image.size.height);
       }
        
        self.arrImage = images;
        self.arrAssetModel = assetModels;
        [self.collectionView reloadData];
        
    }];
    
    //代理
    //imagePickerVC.imagePickerDelegate = self;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

#pragma mark 选择完照片代理
- (void)imagePickerController:(DMImagePickerController *)imagePicker didFinishPickingImages:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos {

    self.arrImage = images;
    [self.collectionView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    self.allowRecordSelection = !self.allowRecordSelection;
}

@end


