//
//  SCPictureCell.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/3/21.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureCell.h"
#import "SCPictureItem.h"
#import "SDWebImageManager.h"
#import "SCActivityIndicatorView.h"
#import "SCToastView.h"
#import "HXImageService.h"
#import "SCPictureBrowser.h"

CGFloat const SCPictureCellRightMargin = 20;
static CGFloat const SCMinMaximumZoomScale = 2;

@interface SCPictureCell()<UIScrollViewDelegate>

@property (nonatomic, strong) SCActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) HXImageService *imageService;
@end

@implementation SCPictureCell

- (HXImageService *)imageService{
    if (!_imageService) {
        _imageService = [[HXImageService alloc] init];
    }
    return _imageService;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self initializeScrollViewWithFrame:frame];
        [self initializeImageView];
        [self initializeIndicatorView];
        [self initializeGesture];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.enableDoubleTap = NO;
    
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - Private Method

- (void)initializeScrollViewWithFrame:(CGRect)frame {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - SCPictureCellRightMargin, frame.size.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    ///iOS 11以后偏移64位的配置 建议放在基类里面
    [self topViewController].extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        [self topViewController].automaticallyAdjustsScrollViewInsets = NO;
        
    }
    [self addSubview:self.scrollView];
}

- (void)initializeImageView {
    _imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];
        
    _flagIcon = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, 100, 80, 80)];
    _flagIcon.image = [UIImage imageNamed:@"voidicon"];
    _flagIcon.hidden = YES;
    
    [self addSubview:_flagIcon];
}

- (void)initializeIndicatorView {
    self.indicatorView = [[SCActivityIndicatorView alloc] initWithStyle:SCActivityIndicatorViewStyleCircleLarge];
    self.indicatorView.center = self.scrollView.center;
    [self addSubview:self.indicatorView];
}

- (void)initializeGesture {
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandler:)];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self addGestureRecognizer:singleTapGesture];
    [self addGestureRecognizer:doubleTapGesture];
    [self addGestureRecognizer:longPressGesture];
}

- (CGSize)ratioSize:(CGSize)originSize ratio:(CGFloat)ratio {
    return CGSizeMake(originSize.width / ratio, originSize.height / ratio);
}

- (UIImage *)thumbnailImage:(UIView *)sourceView {
    UIGraphicsBeginImageContextWithOptions(sourceView.frame.size, YES, 0.0);
    [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)showImage:(UIImage *)image {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:NO];
    }
    self.enableDoubleTap = YES;
    self.imageView.image = image;
    self.imageView.frame = [self imageViewRectWithImageSize:image.size];
    self.imageView.center = self.scrollView.center;
    [self setMaximumZoomScale];
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] init];
        _pan.maximumNumberOfTouches = 1;
        [_pan addTarget:self action:@selector(panHandler:)];
    }
    return _pan;
}
#pragma mark - Public Method

- (void)setEnableDynamicsDismiss:(BOOL)enableDynamicsDismiss {
    _enableDynamicsDismiss = enableDynamicsDismiss;
    if (enableDynamicsDismiss) {
        [self.scrollView addGestureRecognizer:self.pan];
    } else {
        [self.scrollView removeGestureRecognizer:_pan];
    }
}

- (void)setItem:(SCPictureItem *)item{
    _item = item;
    /// 卫真 TODO
    if (item.originImageInfo.isOrigin) {
        return;
    }
    @weakify(self);
    [SVProgressHUD show];
    [[self.imageService getOriginImage:[HXAppInfoManager sharedInstance].userInfo.userId pageId:item.originImageInfo.pageId] subscribeNext:^(NSDictionary *responseDic) {
        @strongify(self);
        [SVProgressHUD dismiss];
        NSString *base64 = responseDic[item.originImageInfo.pageId];
        UIImage *image = [UIImage imageWithData:[GTMBase64 decodeString:base64]];
        item.originImageInfo.image = image;
        item.originImageInfo.isOrigin = YES;
        [self showImage:item.originImageInfo.image];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
        [((SCPictureBrowser *)[self topViewController]) showError:error];
    } completed:^{
    }];
}

- (void)showImageWithItem:(SCPictureItem *)item {
    
    self.item = item;
    self.url = item.url;
    
    if (item.originImageInfo.image) {
        [self showImage:item.originImageInfo.image];
        
    }else if (item.url) {
        // 尝试从缓存里取图片
        [[SDWebImageManager sharedManager].imageCache queryCacheOperationForKey:item.url.absoluteString done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            
            // 如果没有取到图片
            if (!image) {
                // 设置缩略图
                if (item.sourceView) {
                    self.imageView.image = [self thumbnailImage:item.sourceView];
                    self.imageView.frame = CGRectMake(0, 0, item.sourceView.frame.size.width, item.sourceView.frame.size.height);
                    self.imageView.center = [UIApplication sharedApplication].keyWindow.center;
                }
                
                // loading
                [self.indicatorView startAnimating];
                
                // 下载图片
                [[SDWebImageManager sharedManager] loadImageWithURL:item.url options:SDWebImageLowPriority | SDWebImageRetryFailed  progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if ([imageURL isEqual:self.url]) {
                        // 结束loading
                        [self.indicatorView stopAnimating];
                        
                        // 成功下载图片
                        if (image) {
                            self.enableDoubleTap = YES;
                            item.originImageInfo.image = image;
                            self.imageView.image = image;
                            
                            if (item.sourceView) {
                                [UIView animateWithDuration:0.4 animations:^{
                                    self.imageView.frame = [self imageViewRectWithImageSize:image.size];
                                } completion:^(BOOL finished) {
                                    [self setMaximumZoomScale];
                                }];
                            } else {
                                self.imageView.frame = [self imageViewRectWithImageSize:image.size];
                                [self setMaximumZoomScale];
                            }
                        }
                        // 下载图片失败
                        else if (error) {
                            [SCToastView showInView:self.scrollView text:@"下载失败" autoHide:YES];
                        }
                    }

                }
                 ];
            }
            // 从缓存中取到了图片
            else {
                item.originImageInfo.image = image;
                [self showImage:image];
            }
        }];
    }
}

- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize {
    CGFloat heightRatio = imageSize.height / [UIScreen mainScreen].bounds.size.height;
    CGFloat widthRatio = imageSize.width / [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeZero;
    size = [self ratioSize:imageSize ratio:MAX(heightRatio, widthRatio)];
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - size.width) / 2;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - size.height) / 2;
    return CGRectMake(x, y, size.width, size.height);
}

- (void)setMaximumZoomScale {
    if (self.scrollView.frame.size.height > self.imageView.frame.size.height * SCMinMaximumZoomScale) {
        self.scrollView.maximumZoomScale = self.frame.size.height / self.imageView.frame.size.height;
    } else {
        self.scrollView.maximumZoomScale = SCMinMaximumZoomScale;
    }
}

#pragma mark - GestureRecognizer

- (void)singleTapHandler:(UITapGestureRecognizer *)singleTap {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    
    if ([self.delegate respondsToSelector:@selector(pictureCell:singleTap:)]) {
        [self.delegate pictureCell:self singleTap:singleTap];
    }
}

- (void)doubleTapHandler:(UITapGestureRecognizer *)doubleTap {
    if ([self.delegate respondsToSelector:@selector(pictureCell:doubleTap:)]) {
        [self.delegate pictureCell:self doubleTap:doubleTap];
    }
    
    if (!self.enableDoubleTap) {
        return;
    }
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint point = [doubleTap locationInView:doubleTap.view];
        [self.scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(pictureCell:longPress:)]) {
            [self.delegate pictureCell:self longPress:longPress];
        }
    }
}

- (void)panHandler:(UIPanGestureRecognizer *)pan {
    if ([self.delegate respondsToSelector:@selector(pictureCell:pan:)]) {
        [self.delegate pictureCell:self pan:pan];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if (self.enableDynamicsDismiss) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            self.pan.enabled = NO;
        } else {
            self.pan.enabled = YES;
        }
    }
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    
    self.imageView.center = actualCenter;
}


- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
