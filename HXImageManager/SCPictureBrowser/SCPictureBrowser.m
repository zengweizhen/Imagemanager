//
//  SCPictureBrowser.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureBrowser.h"
#import "SCPictureCell.h"
#import "SDWebImageManager.h"
#import "SDWebImagePrefetcher.h"
#import "SCToastView.h"
#import "SCAlertView.h"
static NSString * const reuseIdentifier = @"SCPictureCell";
static CGFloat const kDismissalVelocity = 800.0;

@interface SCPictureBrowser()<UICollectionViewDataSource, UICollectionViewDelegate, SCPictureDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, getter=isFirstShow) BOOL firstShow;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic, getter=isBrowsing) BOOL browsing;

// UIDynamics
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, assign) CGPoint imageDragStartingPoint;
@property (nonatomic, assign) UIOffset imageDragOffsetFromActualTranslation;
@property (nonatomic, assign) UIOffset imageDragOffsetFromImageCenter;
@property (nonatomic, assign) BOOL isDraggingImage;

@end

@implementation SCPictureBrowser
{
    UIActionSheet *_sheet;
    UICollectionView *_collectionView;
    UIPageControl *_pageControl;
    BOOL _isFromShowAction;
}

#pragma mark - Life Cycle

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeCollectionView];
    [self initializePageControl];
    self.firstShow = YES;
    self.browsing = YES;
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    [self setNavigationBarBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];

}

- (void)showError:(NSError *)error{
    if(!error){
        return;
    }else if ([error isKindOfClass:[HXError class]]){
        HXError *errorInfo = (HXError *)error;
        [SVProgressHUD setContainerView:_collectionView];
        [SVProgressHUD showWithStatus:errorInfo.domain];
        [SVProgressHUD dismissWithDelay:0.75];
        [SVProgressHUD setContainerView:nil];
    }else{
        [SVProgressHUD showWithStatus:error.localizedDescription];
        [SVProgressHUD dismissWithDelay:0.75];
    }
}


- (void)setTitle:(NSString *)title{
    
    CGSize maxSize                = CGSizeMake(MAXFLOAT, 44) ;
    CGSize titleSize              = [title sizeWithConstrainedSize:maxSize
                                                              font:[UIFont systemFontOfSize: 18.0]
                                                       lineSpacing:0];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font               = [UIFont systemFontOfSize: 18.0];
    titleLabel.textColor          = ColorWithRGB(51, 51, 51);
    titleLabel.textAlignment      = NSTextAlignmentCenter;
    titleLabel.backgroundColor    = [UIColor clearColor];
    titleLabel.frame    = CGRectMake(0,0,titleSize.width,titleSize.height);
    titleLabel.text               = title;
    self.navigationItem.titleView = titleLabel;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"icon_arrow_blue"];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    // 设置尺寸
    button.bounds = (CGRect){CGPointZero, image.size};
    [button addTarget:self action:@selector(onBack)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    //修改导航栏左右按钮的坐标
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;//这个数值可以根据情况自由变化
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,item];

}

- (void)onBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initializeCollectionView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect frame = self.view.frame;
    frame.size.width += SCPictureCellRightMargin;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = frame.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SCPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    _collectionView.contentSize = CGSizeMake(_collectionView.frame.size.width * self.items.count, 0);
    _collectionView.contentOffset = CGPointMake(self.index * _collectionView.frame.size.width, 0);
    [self.view addSubview:_collectionView];
    
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
//    lineView.backgroundColor = [UIColor separateLineColor];
//    [self.navigationController.navigationBar addSubview:lineView];
}

- (void)initializePageControl {
    _pageControl = [[UIPageControl alloc] init];
    [self setPageControlHidden:YES];
    _pageControl.numberOfPages = self.items.count;
    _pageControl.currentPage = self.index;
    CGPoint center = _pageControl.center;
    center.x = self.view.center.x;
    center.y = CGRectGetMaxY(self.view.frame) - _pageControl.frame.size.height / 2 - 20;
    _pageControl.center = center;
    [self.view addSubview:_pageControl];
}

#pragma mark - Public Method

- (void)show {
    if (!self.items.count || self.index > self.items.count - 1) {
        return;
    }
    self.view.alpha = 1;
    _isFromShowAction = YES;
    self.browsing = YES;
    
    _pageControl.currentPage = self.index;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self setPageControlHidden:self.items.count == 0];
}

- (void)refresh{
    [_collectionView reloadData];
}



#pragma mark - Setter

- (void)setIndex:(NSInteger)index {
    
    self.title = [NSString stringWithFormat:@"查看图片(%ld/%ld)",index+1,self.items.count];
    
    if (_index != index) {
        _index = index;
        if (self.isBrowsing) {
            // 更新page
            _pageControl.currentPage = index;
            // 预加载图片
            [self prefetchPictures];
        }
    }
    if ([self.delegate respondsToSelector:@selector(pictureBrowser:didChangePageAtIndex:)]) {
        [self.delegate pictureBrowser:self didChangePageAtIndex:index];
    }
}

- (void)setItems:(NSArray<SCPictureItem *> *)items {
    _items = [items copy];
    [self layoutData];
}

#pragma mark - Private Method

- (void)layoutData {
    _collectionView.contentSize = CGSizeMake(_collectionView.frame.size.width * self.items.count, 0);
    _collectionView.contentOffset = CGPointMake(self.index * _collectionView.frame.size.width, 0);
    _pageControl.numberOfPages = self.items.count;
    [_collectionView reloadData];
}

- (void)prefetchPictures {
    if (self.numberOfPrefetchURLs <= 0) {
        return;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    if (self.index >= self.numberOfPrefetchURLs) {
        for (NSInteger i = self.index - 1; i >= self.index - self.numberOfPrefetchURLs; i--) {
            SCPictureItem *item = self.items[i];
            if (!item.originImageInfo.image && item.url) {
                [arrM addObject:item.url];
            }
        }
    }
    if (self.index <= (NSInteger)self.items.count - 1 - self.numberOfPrefetchURLs) {
        for (NSInteger i = self.index + 1; i <= self.index + self.numberOfPrefetchURLs; i++) {
            SCPictureItem *item = self.items[i];
            if (!item.originImageInfo.image && item.url) {
                [arrM addObject:item.url];
            }
        }
    }
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[arrM copy]];
}

- (void)configureCellFirstWithItem:(SCPictureItem *)item cell:(SCPictureCell *)cell {
    self.firstShow = NO;
    [self prefetchPictures];
    
    if (item.originImageInfo.image) {
        [self showImage:item.originImageInfo.image item:item cell:cell cacheType:SDImageCacheTypeMemory];
    }
    else if (item.url) {
        [[SDWebImageManager sharedManager].imageCache queryCacheOperationForKey:item.url.absoluteString done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            if (image) {
                item.originImageInfo.image = image;
                [self showImage:image item:item cell:cell cacheType:cacheType];
            } else {
                [cell showImageWithItem:item];
                [self setPageControlHidden:NO];
            }
        }];
    }
}

- (void)showImage:(UIImage *)image item:(SCPictureItem *)item cell:(SCPictureCell *)cell cacheType:(SDImageCacheType)cacheType {
    cell.imageView.image = image;
    
    if (item.sourceView) {
        cell.imageView.frame = [item.sourceView convertRect:item.sourceView.bounds toView:cell];
        if (cacheType == SDImageCacheTypeMemory) { // 如果同步执行这段代码，坐标系转换会有bug，所以手动累加偏移量
            CGRect frame = cell.imageView.frame;
            frame.origin.x += (cell.frame.size.width * self.index);
            cell.imageView.frame = frame;
        }
        [UIView animateWithDuration:0.4 animations:^{
            cell.imageView.frame = [cell imageViewRectWithImageSize:image.size];
        } completion:^(BOOL finished) {
            cell.enableDoubleTap = YES;
            [cell setMaximumZoomScale];
            [self setPageControlHidden:NO];
        }];
    }else {
        [self setPageControlHidden:NO];
        cell.imageView.frame = [cell imageViewRectWithImageSize:image.size];
        cell.alpha = 0;
        [UIView animateWithDuration:0.4 animations:^{
            cell.alpha = 1;
        } completion:^(BOOL finished) {
            cell.enableDoubleTap = YES;
            [cell setMaximumZoomScale];
        }];
    }
}

- (void)setPageControlHidden:(BOOL)hidden {
    if (hidden) {
        _pageControl.hidden = YES;
    } else {
        if (self.items.count > 1 && !self.alwaysPageControlHidden) {
            _pageControl.hidden = NO;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // 是否要特效显示
//    cell.enableDynamicsDismiss = self.items.count == 1 ? YES : NO;
    cell.enableDynamicsDismiss = NO;
    cell.delegate = self;
    
    SCPictureItem *item = self.items[indexPath.item];
    cell.flagIcon.hidden = item.isAbolished == NO;
    cell.item = item;
    if (_isFromShowAction) {
        if (self.isFirstShow) {
            [self configureCellFirstWithItem:item cell:cell];
        } else {
            [cell showImageWithItem:item];
            [self setPageControlHidden:NO];
        }
    }
    else {
        [cell showImageWithItem:item];
        [self setPageControlHidden:NO];
    }
    
    return cell;
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger index = [_collectionView indexPathForItemAtPoint:scrollView.contentOffset].row;
    
    self.index = index;
}

#pragma mark - SCPictureCellDelegate

- (void)pictureCell:(SCPictureCell *)pictureCell singleTap:(UITapGestureRecognizer *)singleTap {
    if (_isFromShowAction) {
        [self dismiss];
    }
}

- (void)pictureCell:(SCPictureCell *)pictureCell doubleTap:(UITapGestureRecognizer *)doubleTap {
    
}

- (void)pictureCell:(SCPictureCell *)pictureCell longPress:(UILongPressGestureRecognizer *)longPress {
    SCPictureItem *item = self.items[self.index];
    if (item.originImageInfo.image) {
        SCAlertView *alertView = [SCAlertView alertViewWithTitle:nil message:nil style:SCAlertViewStyleActionSheet];
        [alertView addAction:[SCAlertAction actionWithTitle:@"保存图片" style:SCAlertActionStyleDefault handler:^(SCAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(item.originImageInfo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }]];
        [alertView addAction:[SCAlertAction actionWithTitle:@"取消" style:SCAlertActionStyleCancel handler:nil]];
        [alertView show];
    }
}

- (void)pictureCell:(SCPictureCell *)pictureCell pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint translation = [pan translationInView:pan.view];
    CGPoint locationInView = [pan locationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    CGFloat vectorDistance = sqrtf(powf(velocity.x, 2)+powf(velocity.y, 2));
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.isDraggingImage = CGRectContainsPoint(pictureCell.imageView.frame, locationInView);
        if (self.isDraggingImage) {
            [self startImageDragging:locationInView translationOffset:UIOffsetZero pictureCell:pictureCell];
        }
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        if (self.isDraggingImage) {
            CGPoint newAnchor = self.imageDragStartingPoint;
            newAnchor.x += translation.x + self.imageDragOffsetFromActualTranslation.horizontal;
            newAnchor.y += translation.y + self.imageDragOffsetFromActualTranslation.vertical;
            self.attachmentBehavior.anchorPoint = newAnchor;
        }
        else {
            self.isDraggingImage = CGRectContainsPoint(pictureCell.imageView.frame, locationInView);
            if (self.isDraggingImage) {
                UIOffset translationOffset = UIOffsetMake(-1*translation.x, -1*translation.y);
                [self startImageDragging:locationInView translationOffset:translationOffset pictureCell:pictureCell];
            }
        }
    }
    else {
        if (vectorDistance > kDismissalVelocity) {
            if (self.isDraggingImage) {
                [self dismissImageWithFlick:velocity pictureCell:pictureCell];
            }
        } else {
            [self cancelCurrentImageDrag:YES pictureCell:pictureCell];
        }
    }
}
- (void)cancelCurrentImageDrag:(BOOL)animated pictureCell:(SCPictureCell *)pictureCell {
    [self.animator removeAllBehaviors];
    self.attachmentBehavior = nil;
    self.isDraggingImage = NO;
    if (animated == NO) {
        pictureCell.imageView.transform = CGAffineTransformIdentity;
        pictureCell.imageView.center = CGPointMake(pictureCell.scrollView.contentSize.width/2.0f, pictureCell.scrollView.contentSize.height/2.0f);
    } else {
        [UIView
         animateWithDuration:0.7
         delay:0
         usingSpringWithDamping:0.7
         initialSpringVelocity:0
         options:UIViewAnimationOptionAllowUserInteraction |
         UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             if (self.isDraggingImage == NO) {
                 pictureCell.imageView.transform = CGAffineTransformIdentity;
                 if (pictureCell.scrollView.dragging == NO && pictureCell.scrollView.decelerating == NO) {
                     pictureCell.imageView.center = CGPointMake(CGRectGetMidX(pictureCell.scrollView.frame), CGRectGetMidY(pictureCell.scrollView.frame));
                 }
             }
         } completion:nil];
    }
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dismissImageWithFlick:(CGPoint)velocity pictureCell:(SCPictureCell *)pictureCell {
    __weak typeof(self)weakSelf = self;
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[pictureCell.imageView] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(velocity.x*0.1, velocity.y*0.1);
    [push setTargetOffsetFromCenter:self.imageDragOffsetFromImageCenter forItem:pictureCell.imageView];
    push.action = ^{
        if ([weakSelf imageViewIsOffscreen:pictureCell]) {
            [weakSelf.animator removeAllBehaviors];
            weakSelf.attachmentBehavior = nil;
            [weakSelf dismiss];
        }
    };
    [self.animator removeBehavior:self.attachmentBehavior];
    [self.animator addBehavior:push];
}

- (void)startImageDragging:(CGPoint)locationInView translationOffset:(UIOffset)translationOffset pictureCell:(SCPictureCell *)pictureCell {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:pictureCell.scrollView];
    self.imageDragStartingPoint = locationInView;
    self.imageDragOffsetFromActualTranslation = translationOffset;
    CGPoint anchor = self.imageDragStartingPoint;
    CGPoint imageCenter = pictureCell.imageView.center;
    UIOffset offset = UIOffsetMake(locationInView.x-imageCenter.x, locationInView.y-imageCenter.y);
    self.imageDragOffsetFromImageCenter = offset;
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:pictureCell.imageView offsetFromCenter:offset attachedToAnchor:anchor];
    [self.animator addBehavior:self.attachmentBehavior];
    UIDynamicItemBehavior *modifier = [[UIDynamicItemBehavior alloc] initWithItems:@[pictureCell.imageView]];
    modifier.angularResistance = [self appropriateAngularResistanceForView:pictureCell.imageView];
    modifier.density = [self appropriateDensityForView:pictureCell.imageView];
    [self.animator addBehavior:modifier];
}

- (BOOL)imageViewIsOffscreen:(SCPictureCell *)pictureCell {
    CGRect visibleRect = [pictureCell.scrollView convertRect:self.view.bounds fromView:self.view];
    return ([self.animator itemsInRect:visibleRect].count == 0);
}

- (CGFloat)appropriateAngularResistanceForView:(UIView *)view {
    CGFloat height = view.bounds.size.height;
    CGFloat width = view.bounds.size.width;
    CGFloat actualArea = height * width;
    CGFloat referenceArea = self.view.bounds.size.width * self.view.bounds.size.height;
    CGFloat factor = referenceArea / actualArea;
    CGFloat defaultResistance = 4.0f; // Feels good with a 1x1 on 3.5 inch displays. We'll adjust this to match the current display.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat resistance = defaultResistance * ((320.0 * 480.0) / (screenWidth * screenHeight));
    return resistance * factor;
}

- (CGFloat)appropriateDensityForView:(UIView *)view {
    CGFloat height = view.bounds.size.height;
    CGFloat width = view.bounds.size.width;
    CGFloat actualArea = height * width;
    CGFloat referenceArea = self.view.bounds.size.width * self.view.bounds.size.height;
    CGFloat factor = referenceArea / actualArea;
    CGFloat defaultDensity = 0.5f; // Feels good on 3.5 inch displays. We'll adjust this to match the current display.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat appropriateDensity = defaultDensity * ((320.0 * 480.0) / (screenWidth * screenHeight));
    return appropriateDensity * factor;
}


// save picture
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [SCToastView showInView:self.view text:@"保存成功" autoHide:YES];
    } else {
        [SCToastView showInView:self.view text:@"保存失败" autoHide:YES];
    }
}

@end
