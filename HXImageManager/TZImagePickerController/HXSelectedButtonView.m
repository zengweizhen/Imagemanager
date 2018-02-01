//
//  HXSelectedButton.m
//  HXFinancePureLine
//
//  Created by Jney on 2017/9/13.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "HXSelectedButtonView.h"
#import "HXOrderDetailResponse.h"


static CGFloat HXSelectedButtonSpace = 2;
static CGFloat HXSelectedButtonHeight = 38;//(33 + 15)


@interface HXSelectedButtonView ()

@property(nonatomic, strong)NSMutableArray *buttonArray;
@property(nonatomic, strong)UIButton *selectedButton;


@end

@implementation HXSelectedButtonView

- (instancetype)initWithTitles:(NSArray *)titles selectedIndex:(NSInteger)index{
    
    self = [super initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, HXSelectedButtonHeight)];
    if (self) {
        
        [self createButtonWithTitles:titles selectedIndex:index];
    }
    return self;
}

-(NSMutableArray *)buttonArray{
    
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (void)createButtonWithTitles:(NSArray *)titles selectedIndex:(NSInteger)index{
    
    self.bgScrollerView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.bgScrollerView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.bgScrollerView];
}

- (void)setObjectTitles:(NSArray *)titles{
    
    _titles = titles;
    __block CGFloat contentWidth = 0;
    
    NSInteger buttonCount = self.buttonArray.count;
    if (buttonCount < _titles.count) {
        NSLog(@"按钮不够");
        
        NSArray *titleArray = [titles subarrayWithRange:NSMakeRange(buttonCount, _titles.count - buttonCount)];
        UIButton *lastButton = [self.buttonArray lastObject];
        __block CGFloat width = lastButton.right;
        if (width == 0) {
            width = 15;
        }
        //__block CGFloat selectedButtonTop = lastButton.top;
        NSArray *models = [HXOrderImageType mj_objectArrayWithKeyValuesArray:titleArray];
        [models enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL * _Nonnull stop) {
            self.titles = titles;
            NSString *obj = @"";
            HXOrderImageSubType *imageModel = (HXOrderImageSubType *)object;
            obj = imageModel.imageName;
            

            UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
            button.backgroundColor = [UIColor cyanColor];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitle:obj forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:ColorWithRGB(244, 244, 244)] forState:UIControlStateSelected];
            
            CGSize size = [obj sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(SCREEN_WIDTH, 15)];
            CGFloat buttonWidth = MAX((self.width - HXSelectedButtonSpace * 3)/4.0, (size.width + 25));
            if ([obj rangeOfString:@"个月"].location != NSNotFound) {
                buttonWidth = (self.width - HXSelectedButtonSpace * 3)/4.0;
            }
            button.frame = CGRectMake(width, 0, buttonWidth, 38);
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:ColorWithRGB(51, 51, 51) forState:UIControlStateSelected];

            button.tag = buttonCount + idx;
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonArray addObject:button];
            [self.bgScrollerView addSubview:button];
            
            width = button.right + HXSelectedButtonSpace;

            if (idx == self.selectedIndex) {
                ///默认选中一个
                //[self clickButton:button];
                self.selectedButton.selected = !self.selectedButton.selected;
                ///这次选中的按钮
                self.selectedButton = button;
                button.selected = !button.selected;
               
            }
        }];
    }else if (self.buttonArray.count > _titles.count) {
        ///按钮多了
        for (NSInteger i = _titles.count; i < self.buttonArray.count; i++) {
            UIButton *button = self.buttonArray[i];
            button.hidden = YES;
        }
    }

    NSArray *titleModels = [HXOrderImageSubType mj_objectArrayWithKeyValuesArray:_titles];
        [titleModels enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = self.buttonArray[idx];
            button.hidden = NO;
            UIBezierPath *maskPath;
            //根据矩形画带圆角的曲线
            maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                             byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                   cornerRadii:CGSizeMake(8, 8)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
            NSString *obj = @"";
            HXOrderImageSubType *imageModel = (HXOrderImageSubType *)object;
            obj = imageModel.imageName;
            [button setTitle:obj forState:UIControlStateNormal];
            CGSize size = [obj sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(SCREEN_WIDTH, 15)];
            CGFloat buttonWidth = MAX((self.width - HXSelectedButtonSpace * 3)/4.0, (size.width + 25));
            if ([button.titleLabel.text rangeOfString:@"个月"].location != NSNotFound) {
                buttonWidth = (self.width - HXSelectedButtonSpace * 3)/4.0;
            }
            contentWidth = button.right + HXSelectedButtonSpace;
            if (idx == self.selectedIndex) {
                //[self clickButton:button];
                ///上一次选中的按钮
                self.selectedButton.selected = !self.selectedButton.selected;
                ///这次选中的按钮
                self.selectedButton = button;
                button.selected = !button.selected;
    

            }
            self.selectedScrollerViewHeight = button.bottom;
        }];
    self.frame = CGRectMake(0, self.top, SCREEN_WIDTH, self.selectedScrollerViewHeight);
    self.bgScrollerView.frame = CGRectMake(self.bgScrollerView.left, self.bgScrollerView.top, self.bgScrollerView.width, self.selectedScrollerViewHeight);
    self.bgScrollerView.contentSize = CGSizeMake(contentWidth + 10, self.bgScrollerView.height);

}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    self.selectedButton.selected = !self.selectedButton.selected;
    if (_buttonArray.count != 0) {
        ///这次选中的按钮
        self.selectedButton = self.buttonArray[selectedIndex];
        self.selectedButton.selected = !self.selectedButton.selected;
    }
    
}

- (void)clickButton:(UIButton *)btn{
    
    NSInteger from = self.selectedButton.tag;
    ///上一次选中的按钮
    self.selectedButton.selected = !self.selectedButton.selected;
    ///这次选中的按钮
    self.selectedButton = btn;
    btn.selected = !btn.selected;
    
    if ([self.delegate respondsToSelector:@selector(hx_selectedButtonViewDelegate:fromIndex:toIndex:point:)]) {
        HXOrderImageSubType *imageSubType = self.titles[btn.tag];
        HXSelectedModel *model = [[HXSelectedModel alloc] init];
        model.titleStr = btn.titleLabel.text;
        model.codeStr = imageSubType.classCode;
        model.selectedIndex = btn.tag;
        CGPoint point = self.bgScrollerView.contentOffset;
        [self.delegate hx_selectedButtonViewDelegate:model fromIndex:from toIndex:btn.tag point:point];
    }
}

@end

@implementation HXSelectedModel

@end
