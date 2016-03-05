//
//  FunnyImageCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FunnyImageCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation FunnyImageCell



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //创建标题lable;
        self.digestLable=[[UILabel alloc]initWithFrame:CGRectMake(0.0266*WIDTH, 0.0133*WIDTH, 0.946*WIDTH, 0.2667*WIDTH)];
        //创建imgeview 放图片
        self.imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0.0266*WIDTH, CGRectGetMaxY(self.digestLable.frame)+0.0266*WIDTH, 0.9466*WIDTH, 0.8*WIDTH)];
        //设置文本自动换行
        self.digestLable.numberOfLines=0;
        //设置字体大小
        self.digestLable.font=[UIFont fontWithName:WAWA_FONT size:17];
        
        [self.contentView addSubview:self.digestLable];
        [self.contentView addSubview:self.imgView];
        
    }
    
    return self;
}
//获取文本的高度
+(CGFloat )textLableHeight:(NSString *)text{
    //限定宽度
    CGSize  size=CGSizeMake(360, 1000);
    
    NSDictionary *dic=@{NSFontAttributeName:[UIFont fontWithName:WAWA_FONT size:17] };
    
    //返回一个矩形区域
    CGRect rect=[text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) attributes:dic context:nil];
    return rect.size.height;
}





-(void)setModel:(FunModel *)model{
    if (_model!=model) {
        _model=model;
        self.digestLable.text=model.digest;
        
        //修改内容的frame
        CGFloat height=[[self class] textLableHeight:self.model.digest];
        CGRect frame=self.digestLable.frame;
        frame.size.height=height;
        self.digestLable.frame=frame;
        
        NSString * str=model.pixel;
        //字符串截取 获取图片的高和宽
        NSRange range=NSMakeRange(0, 3);
        NSRange range1=NSMakeRange(4, 3);
        //将图片的高和宽转化为浮点型
        NSString * widthString=[str substringWithRange:range];
        CGFloat imgWidth=[widthString floatValue];
        
        NSString * heightString=[str substringWithRange:range1];
        CGFloat imgHeight =[heightString floatValue];
        //获得imgview的高度
        CGFloat  heightX=0.9466*WIDTH*imgHeight/imgWidth;
        //修改imgview的frame
        CGRect imgFrame=self.imgView.frame;
        imgFrame.size.height=heightX;
        imgFrame.origin.y=CGRectGetMaxY(frame) + 5;
        self.imgView.frame=imgFrame;
        //第三方下载图片
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.imgsrc]];

        
        
    }
}





- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
