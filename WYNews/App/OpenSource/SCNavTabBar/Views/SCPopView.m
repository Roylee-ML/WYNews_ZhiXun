//
//  SCPopView.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCPopView.h"
#import "CommonMacro.h"

@implementation SCPopView

-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
//        self.frame = frame;
        self.backgroundColor = [UIColor colorWithRed:250.0/255 green:250.0/255 blue:240.0/255 alpha:1];
    }
    return self;
}

#pragma mark - Private Methods
#pragma mark -
- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles andHeight:(CGFloat)height
{
    NSMutableArray *widths = [@[] mutableCopy];
    
    for (NSString *title in titles)
    {
        CGSize size = CGSizeMake(1000, height);
        NSDictionary *dic=@{NSFontAttributeName:[UIFont systemFontOfSize:TitleFont_Size]};
        CGRect rect=[title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
        
        NSNumber *width = [NSNumber numberWithFloat:rect.size.width + 40.0f];
        [widths addObject:width];
    }
    
    return widths;
}

- (void)updateSubViewsWithItemWidths:(NSArray *)itemWidths;
{
    CGFloat buttonX = DOT_COORDINATE +10;
    CGFloat buttonY = self.titleHeight/5;
    for (NSInteger index = 0; index < [itemWidths count]; index++)
    {
        
#pragma mark ----- 设置标题字体 -----
        
        UILabel * titleLable = [[UILabel alloc]initWithFrame:CGRectMake(buttonX, buttonY, [itemWidths[index] floatValue], self.titleHeight*3/4)];
        titleLable.textColor = [UIColor blackColor];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.text = _itemNames[index];
//        titleLable.font = [UIFont fontWithName:TITLE_FONT size:TitleFont_Size];
        titleLable.font = [UIFont systemFontOfSize:TitleFont_Size];;
        titleLable.userInteractionEnabled = YES;
        [self addSubview:titleLable];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, [itemWidths[index] floatValue], self.titleHeight*3/4)];
        button.tag = 100+index;
        
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [titleLable addSubview:button];
        
        buttonX += [itemWidths[index] floatValue] - 10;
        
        @try {
            if ((buttonX + [itemWidths[index + 1] floatValue]) >= self.frame.size.width - (self.titleHeight - 10))
            {
                buttonX = DOT_COORDINATE + 10;
                buttonY += self.titleHeight*3/4 + self.titleHeight/8;
                
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}

- (void)itemPressed:(UIButton *)button
{
    [_delegate itemPressedWithIndex:button.tag - 100];
}

#pragma mark - Public Methods
#pragma marl -
- (void)setItemNames:(NSArray *)itemNames
{
    _itemNames = itemNames;
    
    NSArray *itemWidths = [self getButtonsWidthWithTitles:itemNames andHeight:_titleHeight];
    [self updateSubViewsWithItemWidths:itemWidths];
    
    //记得在这里改动self的frame来自适应文字button的高度，将上一个方法加上返回值
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
