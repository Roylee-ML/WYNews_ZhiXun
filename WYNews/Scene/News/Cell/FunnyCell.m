//
//  FunnyCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FunnyCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation FunnyCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //创建lable
        self.digestLable=[[UILabel alloc]initWithFrame:CGRectMake(0.027*WIDTH, 0.053*WIDTH, 0.946*WIDTH, 0.2667*WIDTH)];
        //设置自动换行
        self.digestLable.numberOfLines=0;
        //设置字体大小
        self.digestLable.font=[UIFont fontWithName:WAWA_FONT size:17];
        [self.contentView addSubview:self.digestLable];
        
    }
    
    return self;
}



- (void)awakeFromNib {
    // Initialization code
}
//获取文本高度
+(CGFloat )textLableHeight:(NSString *)text{
    //限定宽度
    CGSize  size=CGSizeMake(0.946*WIDTH, 10*WIDTH);
    NSDictionary *dic=@{NSFontAttributeName:[UIFont fontWithName:WAWA_FONT size:17] };
    //返回是一个矩形区域
    CGRect rect=[text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) attributes:dic context:nil];
    return rect.size.height;
}





-(void)setModel:(FunModel *)model{
    if (_model!=model) {
        _model=model;
        self.digestLable.text=model.digest;
        
        //修改lable的frame
        CGFloat height=[[self class] textLableHeight:self.model.digest];
        CGRect frame=self.digestLable.frame;
        frame.size.height=height;
        self.digestLable.frame=frame;
               

    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
