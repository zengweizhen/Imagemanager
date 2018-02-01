//
//  HXHeaderFooterView.h
//  HXImageManager
//
//  Created by Jney on 2018/1/17.
//  Copyright © 2018年 Jney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXImageCellHeaderViewModel : NSObject

/// 标题
@property (nonatomic, strong) NSString *titleString;
/// 是否在编辑状态
@property (nonatomic, assign) BOOL isOnEditing;
/// headertFooterView所在的row
@property (nonatomic, assign) NSInteger rowNumber;

@end


@class HXImageCellHeaderView;

@protocol HXImageCellHeaderViewDelegte<NSObject>
/// 点击编辑按钮
- (void)hxClickEditButton:(UIButton *)button headerFooterView:(HXImageCellHeaderView *)headerFooterView;
/// 点击排序按钮
- (void)hxClickSortButton:(UIButton *)button headerFooterView:(HXImageCellHeaderView *)headerFooterView;
/// 点击删除/作废按钮
- (void)hxClickDeleteButton:(UIButton *)button headerFooterView:(HXImageCellHeaderView *)headerFooterView;

@end


@interface HXImageCellHeaderView : UIView

@property (nonatomic, strong) HXImageCellHeaderViewModel *headerFooterModel;
@property (nonatomic, weak  ) id<HXImageCellHeaderViewDelegte> delegate;

@end
