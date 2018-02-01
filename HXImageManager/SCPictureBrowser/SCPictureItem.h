//
//  SCPictureItem.h
//  SCPictureBrowser
//
//  Created by sichenwang on 16/4/5.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCPictureItem : NSObject

@property (nullable, nonatomic, strong) NSURL *url;
@property (nullable, nonatomic, strong) HXImageModel *originImageInfo;
@property (nullable, nonatomic, strong) UIView *sourceView;
/**
 是否是缩略图,默认值为YES
 */
@property (nonatomic, assign) BOOL isThumblenail;
@property (nonatomic, assign) BOOL isAbolished;

- (void)makeAbolished;

@end

NS_ASSUME_NONNULL_END
