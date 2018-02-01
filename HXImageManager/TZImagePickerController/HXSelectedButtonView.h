//
//  HXSelectedButton.h
//  HXFinancePureLine
//
//  Created by Jney on 2017/9/13.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXSelectedModel : NSObject

/**
 选择按钮的标题
 */
@property(nonatomic, strong)NSString *titleStr;

/**
 选择按钮对应的code
 */
@property(nonatomic, strong)NSString *codeStr;

/**
 选中的下标
 */
@property(nonatomic, assign)NSInteger selectedIndex;

@end

@protocol HXSelectedButtonViewDelegate <NSObject>

@optional


/**
 按钮点击代理

 @param model 选择按钮的模型
 */
- (void)hx_selectedButtonViewDelegate:(HXSelectedModel *)model fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)endIndex point:(CGPoint)point;

@end


@interface HXSelectedButtonView : UIView

@property(nonatomic, strong)NSArray *titles;

@property(nonatomic, weak) id<HXSelectedButtonViewDelegate> delegate;
@property(nonatomic, assign) CGFloat selectedScrollerViewHeight;

@property(nonatomic, strong)UIScrollView *bgScrollerView;
/**
 选中的按钮下标
 */
@property(nonatomic, assign)NSInteger selectedIndex;

/**
 初始化按钮视图

 @param titles 按钮title数组
 @return return value description
 */
- (instancetype)initWithTitles:(NSArray *)titles selectedIndex:(NSInteger)index;

- (void)setObjectTitles:(NSArray *)titles;

@end
