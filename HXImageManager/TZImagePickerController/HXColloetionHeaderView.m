//
//  HXColloetionHeaderView.m
//  Kuoke
//
//  Created by Jney on 2017/12/15.
//  Copyright © 2017年 Hxxc. All rights reserved.
//

#import "HXColloetionHeaderView.h"
#import "HXImageCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZAssetModel.h"
#import <Photos/Photos.h>

@interface HXColloetionHeaderView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *itemModels;
@property (nonatomic, assign) NSInteger count;

@end

@implementation HXColloetionHeaderView

- (instancetype)initWithItemArray:(NSArray *)items{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80 * displayScale);
        self.backgroundColor = [UIColor whiteColor];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        lineView.backgroundColor = [UIColor separateLineColor];
        [self addSubview:lineView];
        [self setItemObjects:items];
        [self createCollectionView];
    }
    return self;
}

- (void)createCollectionView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 24, 60 * displayScale) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    flowLayout.minimumLineSpacing = 4;
    flowLayout.minimumInteritemSpacing = 4;
    flowLayout.itemSize = CGSizeMake(60 * displayScale, 60 * displayScale);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[HXImageCollectionViewCell class] forCellWithReuseIdentifier:@"HXImageCollectionViewCell"];
    [self addSubview:self.collectionView];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HXImageCollectionViewCell *cell = (HXImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HXImageCollectionViewCell" forIndexPath:indexPath];
    cell.imageModel = self.itemModels[indexPath.row];
    
    if (indexPath.row == self.selectedIndex) {
        [cell.layer setBorderColor:[UIColor blueTitleColor].CGColor];
        [cell.layer setBorderWidth:2.5];
    }else{
        [cell.layer setBorderColor:[UIColor separateLineColor].CGColor];
        [cell.layer setBorderWidth:1];
    }
    return cell;
    
}

- (void)setItemObjects:(NSArray *)items{
    self.count = items.count;
    self.itemModels = [NSMutableArray array];
    for (NSInteger i = 0; i < items.count; i++) {
        TZAssetModel *model = items[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                HXImageModel *modelA = [[HXImageModel alloc] init];
                modelA.image = [UIImage imageWithData:imageData];
                modelA.pageStatus = @"1";
                [self.itemModels addObject:modelA];
                if (i == (items.count -1)) {
                    [self.collectionView reloadData];
                    
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)model.asset;
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                CGImageRef thumbnailImageRef = alAsset.thumbnail;
                UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
                HXImageModel *modelA = [[HXImageModel alloc] init];
                modelA.image = thumbnailImage;
                modelA.pageStatus = @"1";
                [self.itemModels addObject:modelA];
                if (i == (items.count -1)) {
                    [self.collectionView reloadData];
                }
            });
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndex = indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(hxColloetionHeaderViewDelegteClickItemIndexPath:)]) {
        [self.delegate hxColloetionHeaderViewDelegteClickItemIndexPath:indexPath];
    }
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    [self.collectionView reloadData];
}

- (void)relodCollectionFooterView:(NSInteger )index selected:(BOOL)selected{
    
    if (self.itemModels.count != self.count) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    HXImageModel *model = self.itemModels[index];
    model.showMaskView = selected;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
