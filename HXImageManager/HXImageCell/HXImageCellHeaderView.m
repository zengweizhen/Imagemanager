//
//  HXHeaderFooterView.m
//  HXImageManager
//
//  Created by Jney on 2018/1/17.
//  Copyright © 2018年 Jney. All rights reserved.
//

#import "HXImageCellHeaderView.h"

@interface HXImageCellHeaderView ()

@property (nonatomic, strong) UILabel *sectionLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *sortButton;
/// 删除作废按钮
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation HXImageCellHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        /// 编辑按钮
        self.editButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, 0, 44, 44)];
        self.editButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.editButton setBackgroundColor:[UIColor cyanColor]];
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [self.editButton setTitle:@"取消" forState:UIControlStateSelected];
        [self.editButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
        [self.editButton addTarget:self action:@selector(clickEditButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.editButton];
        
        /// 排序按钮
        self.sortButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, 0, 44, 44)];
        self.sortButton.hidden = YES;
        self.sortButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.sortButton setBackgroundColor:[UIColor cyanColor]];
        [self.sortButton setTitle:@"排序" forState:UIControlStateNormal];
        [self.sortButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
        [self.sortButton addTarget:self action:@selector(clickSortButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sortButton];
        
        /// 删除作废
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, 0, 44, 44)];
        self.deleteButton.hidden = YES;
        self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.deleteButton setBackgroundColor:[UIColor cyanColor]];
        [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, -4, 0)];
        [self.deleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
        
        self.sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.sectionLabel.font = [UIFont systemFontOfSize:16];
        self.sectionLabel.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.sectionLabel];
    }
    return self;
}

- (void)setHeaderFooterModel:(HXImageCellHeaderViewModel *)headerFooterModel{
    _headerFooterModel = headerFooterModel;
    self.sectionLabel.text = headerFooterModel.titleString;
    if (headerFooterModel.isOnEditing) {
        self.editButton.selected = YES;
        self.sortButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.sortButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44 * 2, 0, 44, 44);
        self.deleteButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44 * 3, 0, 44, 44);
        self.sectionLabel.frame = CGRectMake(15, 9, [UIScreen mainScreen].bounds.size.width - 30 - 44 * 3 - 15, 35);
    }else{
        self.editButton.selected = NO;
        self.sortButton.hidden = YES;
        self.deleteButton.hidden = YES;
        self.sectionLabel.frame = CGRectMake(15, 9, [UIScreen mainScreen].bounds.size.width/2.0, 35);
    }

}
/*
- (void)updateUI:(BOOL)isOnEditing{
    
    if (isOnEditing) {
        self.editButton.selected = YES;
        self.sortButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.sectionLabel.frame = CGRectMake(15, 9, [UIScreen mainScreen].bounds.size.width - 30 - 44 * 3 - 15, 35);
        [self showButton];
    }else{
        self.editButton.selected = NO;
        self.sectionLabel.frame = CGRectMake(15, 9, [UIScreen mainScreen].bounds.size.width/2.0, 35);
        [self hiddenButton];
    }
}

- (void)hiddenButton{
    [UIView animateWithDuration:0.3 animations:^{
        self.sortButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, 0, 44, 44);
        self.deleteButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, 0, 44, 44);
    } completion:^(BOOL finished) {
        self.sortButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }];
}

- (void)showButton{
    [UIView animateWithDuration:0.3 animations:^{
        self.sortButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44 * 2, 0, 44, 44);
        self.deleteButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44 * 3, 0, 44, 44);
    }];
}
*/
#pragma mark - 私有方法 按钮点击事件

- (void)clickEditButton:(UIButton *)button{
    
    NSLog(@"编辑按钮");
    if (self.delegate && [self.delegate respondsToSelector:@selector(hxClickEditButton:headerFooterView:)]) {
        [self.delegate hxClickEditButton:button headerFooterView:self];
        
    }
}

- (void)clickSortButton:(UIButton *)button{
    
    NSLog(@"排序");
}

- (void)clickDeleteButton:(UIButton *)button{
    
    NSLog(@"删除");
}

@end


@implementation HXImageCellHeaderViewModel


@end
