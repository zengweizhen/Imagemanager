//
//  HXColloetionHeaderView.h
//  Kuoke
//
//  Created by Jney on 2017/12/15.
//  Copyright © 2017年 Hxxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HXColloetionHeaderViewDelegte<NSObject>

- (void)hxColloetionHeaderViewDelegteClickItemIndexPath:(NSIndexPath *)indexPath;

@end

@interface HXColloetionHeaderView : UIView

@property (nonatomic, weak) id<HXColloetionHeaderViewDelegte> delegate;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)setItemObjects:(NSArray *)items;

- (instancetype)initWithItemArray:(NSArray *)items;

- (void)relodCollectionFooterView:(NSInteger )index selected:(BOOL)selected;

@end
