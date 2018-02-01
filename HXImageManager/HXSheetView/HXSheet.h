//
//  HXSheet.h
//  huaxiafinance_user
//
//  Created by Jney on 16/3/9.
//  Copyright © 2016年 Jney. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HXSheetDelegate <NSObject>

@optional
- (void)cc_actionSheetDidSelectedIndex:(NSInteger)index;

@end


@interface HXSheet : UIView

@property (strong, nonatomic) id<HXSheetDelegate> delegate;

+ (instancetype)shareSheet;
/**
 区分取消和选择,使用array
 回调使用协议
 */
- (void)cc_actionSheetWithSelectArray:(NSArray *)array cancelTitle:(NSString *)cancel delegate:(id<HXSheetDelegate>)delegate;


@end
